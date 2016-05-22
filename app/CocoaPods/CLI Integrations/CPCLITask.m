#import "CPANSIEscapeHelper.h"
#import "CPUserProject.h"
#import "CPCLITask.h"
#import "NSArray+Helpers.h"

@interface CPCLITask ()

@property (nonatomic, weak) id<CPCLITaskDelegate> delegate;

@property (nonatomic, weak) NSString *workingDirectory;
@property (nonatomic, copy) NSString *command;
@property (nonatomic, copy) NSArray *arguments;

@property (nonatomic) NSTask *task;
@property (nonatomic) NSQualityOfService qualityOfService;
@property (nonatomic) NSProgress *progress;
@property (nonatomic, copy) NSAttributedString *output;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) int terminationStatus;

@end

@implementation CPCLITask

#pragma mark - Initialization

- (instancetype)initWithUserProject:(CPUserProject *)userProject
                            command:(NSString *)command
                          arguments:(NSArray *)arguments
                           delegate:(id<CPCLITaskDelegate>)delegate
                   qualityOfService:(NSQualityOfService)qualityOfService
{
  return [self initWithWorkingDirectory:[[userProject.fileURL URLByDeletingLastPathComponent] path]
                                command:command
                              arguments:arguments
                               delegate:delegate
                       qualityOfService:qualityOfService];
}

- (instancetype)initWithWorkingDirectory:(NSString *)workingDirectory
                                 command:(NSString *)command
                               arguments:(NSArray *)arguments
                                delegate:(id<CPCLITaskDelegate>)delegate
                        qualityOfService:(NSQualityOfService)qualityOfService
{
  self = [super init];
  if (self) {
    self.workingDirectory = workingDirectory;
    self.command = command;
    self.arguments = [[arguments map:^ id (id arg) {
      return [arg stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    }] reject:^ BOOL (NSString *arg) {
      return arg.length == 0;
    }];
    self.delegate = delegate;
    self.qualityOfService = qualityOfService;
    self.terminationStatus = 1;
  }
  
  return self;
}

#pragma mark - Start/End Task

- (void)cancel
{
  [self.task interrupt];
  [self.progress cancel];
}

- (void)run
{
  // Create an indetermine progress bar since we have no way to track it for now.
  self.progress = [[NSProgress alloc] initWithParent:nil userInfo:nil];
  self.progress.totalUnitCount = -1;

  NSDictionary *environment = @{
                                @"HOME": NSHomeDirectory(),
                                @"LANG": @"en_GB.UTF-8",
                                @"TERM": @"xterm-256color"
                                };

  NSString *workingDirectory = self.workingDirectory;
  NSString *launchPath = @"/bin/sh";
  NSString *envBundleScript = [[NSBundle mainBundle] pathForResource:@"bundle-env"
                                                              ofType:nil
                                                         inDirectory:@"bundle/bin"];

  NSArray *arguments = [@[envBundleScript, @"pod", self.command] arrayByAddingObjectsFromArray:self.arguments];
  if (self.colouriseOutput) {
    arguments = [arguments arrayByAddingObject:@"--ansi"];
  }

  if (self.verboseOutput) {
    arguments = [arguments arrayByAddingObject:@"--verbose"];
  }

#ifdef DEBUG
  NSString *and = [NSUserName() isEqualToString:@"orta"] ? @"; and" : @"&&";
  NSString *args = [arguments componentsJoinedByString:@" "];
  NSLog(@"$\n cd '%@' %@ env HOME='%@' LANG='%@' TERM='%@' %@ %@", workingDirectory, and,
        environment[@"HOME"],
        environment[@"LANG"],
        environment[@"TERM"],
        launchPath,
        args);
#endif

  self.task = [NSTask new];
  self.task.qualityOfService = self.qualityOfService;
  self.task.launchPath = launchPath;
  self.task.arguments = arguments;
  self.task.environment = environment;
  self.task.currentDirectoryPath = workingDirectory;

  NSPipe *outputPipe = [NSPipe pipe];
  self.task.standardOutput = outputPipe;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(outputAvailable:)
                                               name:NSFileHandleDataAvailableNotification
                                             object:[outputPipe fileHandleForReading]];
  [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotifyForModes:@[NSDefaultRunLoopMode, NSEventTrackingRunLoopMode]];

  NSPipe *errorPipe = [NSPipe pipe];
  self.task.standardError = errorPipe;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(outputAvailable:)
                                               name:NSFileHandleDataAvailableNotification
                                             object:[errorPipe fileHandleForReading]];
  [[errorPipe fileHandleForReading] waitForDataInBackgroundAndNotifyForModes:@[NSDefaultRunLoopMode, NSEventTrackingRunLoopMode]];
  self.running = true;
  [self.task launch];
}

#pragma mark - Command output

// Not doing anything differently with stdout vs stderr atm.
- (void)outputAvailable:(NSNotification *)notification
{
  NSFileHandle *fileHandle = notification.object;
  NSData *data = fileHandle.availableData;

  if (data.length > 0 && [self.delegate respondsToSelector:@selector(task:didUpdateOutputContents:)]) {
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self appendTaskOutput:output];
  }

  if (self.task.isRunning) {
    [fileHandle waitForDataInBackgroundAndNotifyForModes:@[NSDefaultRunLoopMode, NSEventTrackingRunLoopMode]];
  } else {
    [self taskDidFinish];
  }
}

- (void)appendTaskOutput:(NSString *)rawOutput
{
  NSAttributedString *attributedOutput = ANSIUnescapeString(rawOutput);
  if (self.output) {
    NSMutableAttributedString *existingOutput = [self.output mutableCopy];
    [existingOutput appendAttributedString:attributedOutput];
    self.output = existingOutput;
  } else {
    self.output = attributedOutput;
  }

  [self.delegate task:self didUpdateOutputContents:self.output];
}

- (void)taskDidFinish
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSFileHandleDataAvailableNotification
                                                object:nil];

  self.terminationStatus = self.task.terminationStatus;

  // Setting to `nil` signals through bindings that task has finished.
  self.task = nil;

  // Mark the task as complete.
  self.progress.totalUnitCount = 1;
  self.progress.completedUnitCount = 1;
  self.running = false;
  if ([self.delegate respondsToSelector:@selector(taskCompleted:)]) {
    [self.delegate taskCompleted:self];
  }
}

- (BOOL)finishedSuccessfully
{
  return self.terminationStatus == 0;
}

#pragma mark - Utilities

static NSAttributedString *ANSIUnescapeString(NSString *input)
{
  static CPANSIEscapeHelper *cpANSIEscapeHelper = nil;
  static dispatch_once_t onceToken = 0;
  dispatch_once(&onceToken, ^{
    // Re-use the font that the text editor is configured to use.
    cpANSIEscapeHelper = [[CPANSIEscapeHelper alloc] init];
  });

  return [cpANSIEscapeHelper attributedStringWithANSIEscapedString:input];
}

@end
