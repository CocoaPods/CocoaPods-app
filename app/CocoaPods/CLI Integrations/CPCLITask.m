#import "CPANSIEscapeHelper.h"
#import "CPUserProject.h"
#import "CPCLITask.h"

@interface CPCLITask ()

@property (nonatomic, weak) id<CPCLITaskDelegate> delegate;

@property (nonatomic, weak) CPUserProject *userProject;
@property (nonatomic, copy) NSString *command;

@property (nonatomic) NSTask *task;
@property (nonatomic) NSQualityOfService qualityOfService;
@property (nonatomic) NSProgress *progress;
@property (nonatomic, copy) NSAttributedString *output;
@property (nonatomic, assign) BOOL running;
@end

@implementation CPCLITask

#pragma mark - Initialization

- (instancetype)initWithUserProject:(CPUserProject *)userProject
                            command:(NSString *)command
                           delegate:(id<CPCLITaskDelegate>)delegate
                   qualityOfService:(NSQualityOfService)qualityOfService
{
  if (self = [super init]) {
    self.userProject = userProject;
    self.command = command;
    self.delegate = delegate;
    self.qualityOfService = qualityOfService;
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
  self.progress = [NSProgress discreteProgressWithTotalUnitCount:-1];

  NSDictionary *environment = @{
                                @"HOME": NSHomeDirectory(),
                                @"LANG": @"en_GB.UTF-8",
                                @"TERM": @"xterm-256color"
                                };

  NSString *workingDirectory = [[self.userProject.fileURL URLByDeletingLastPathComponent] path];
  NSString *launchPath = @"/bin/sh";
  NSString *envBundleScript = [[NSBundle mainBundle] pathForResource:@"bundle-env"
                                                              ofType:nil
                                                         inDirectory:@"bundle/bin"];

  NSArray *arguments = @[envBundleScript, @"pod", self.command, @"--ansi"];
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CPShowVerboseCommandOutput"]) {
    arguments = [arguments arrayByAddingObject:@"--verbose"];
  }

#ifdef DEBUG
  NSString *args = [arguments componentsJoinedByString:@" "];
  NSLog(@"$ cd '%@' && env HOME='%@' LANG='%@' TERM='%@' %@ %@", workingDirectory,
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
  [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];

  NSPipe *errorPipe = [NSPipe pipe];
  self.task.standardError = errorPipe;
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(outputAvailable:)
                                               name:NSFileHandleDataAvailableNotification
                                             object:[errorPipe fileHandleForReading]];
  [[errorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
  self.running = true;
  [self.task launch];
}

#pragma mark - Command output

// Not doing anything differently with stdout vs stderr atm.
- (void)outputAvailable:(NSNotification *)notification
{
  NSFileHandle *fileHandle = notification.object;
  NSData *data = fileHandle.availableData;

  if (data.length > 0) {
    NSString *output = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self appendTaskOutput:output];
  }

  if (self.task.isRunning) {
    [fileHandle waitForDataInBackgroundAndNotify];
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

  NSUserNotification *completionNotification = [[NSUserNotification alloc] init];
  completionNotification.title = NSLocalizedString(@"WORKSPACE_GENERATED_NOTIFICATION_TITLE", nil);
  completionNotification.subtitle = [[self.userProject.fileURL relativePath] stringByAbbreviatingWithTildeInPath];
  [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:completionNotification];

  // Setting to `nil` signals through bindings that task has finished.
  self.task = nil;

  // Mark the task as complete.
  self.progress.totalUnitCount = 1;
  self.progress.completedUnitCount = 1;
  self.running = false;
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
