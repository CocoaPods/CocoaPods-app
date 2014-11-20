#import "CPUserProject.h"
#import <Fragaria/MGSFragariaFramework.h>

@interface CPUserProject ()
@property (weak) IBOutlet NSView *containerView;
// Such sin.
// TODO: Add real custom window controllers.
@property (strong) IBOutlet NSWindow *progressWindow;
@property (assign) IBOutlet NSTextView *progressOutputView;

@property (strong) MGSFragaria *editor;
@property (strong) NSString *contents;
@property (strong) NSTask *task;
@end

@implementation CPUserProject

- (NSString *)windowNibName;
{
  return @"CPUserProject";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)controller;
{
  [super windowControllerDidLoadNib:controller];

  self.editor = [MGSFragaria new];
  [self.editor setObject:self forKey:MGSFODelegate];
  [self.editor setSyntaxColoured:YES];
  [self.editor setSyntaxDefinitionName:@"Ruby"];
  [self.editor embedInView:self.containerView];
  [self.editor setString:self.contents];

  NSTextView *textView = [self.editor objectForKey:ro_MGSFOTextView];
  self.undoManager = textView.undoManager;
}

- (void)textDidChange:(NSNotification *)notification;
{
  NSTextView *textView = notification.object;
  self.contents = textView.string;
}

#pragma mark -
#pragma mark Persistance

- (BOOL)readFromURL:(NSURL *)absoluteURL
             ofType:(NSString *)typeName
              error:(NSError **)outError;
{
  if ([[absoluteURL lastPathComponent] isEqualToString:@"Podfile"]) {
    self.contents = [NSString stringWithContentsOfURL:absoluteURL
                                             encoding:NSUTF8StringEncoding
                                                error:outError];
    if (self.contents != nil) {
      return YES;
    }
  }
  return NO;
}

- (BOOL)writeToURL:(NSURL *)absoluteURL
            ofType:(NSString *)typeName
             error:(NSError **)outError;
{
  return [self.contents writeToURL:absoluteURL
                        atomically:YES
                          encoding:NSUTF8StringEncoding
                             error:outError];
}

#pragma mark -
#pragma mark Progress sheet

+ (NSSet *)keyPathsForValuesAffectingProgressButtonTitle;
{
  return [NSSet setWithObject:@"task"];
}

- (NSString *)progressButtonTitle;
{
  return self.task == nil ? @"Done" : @"Cancel";
}

- (void)presentProgressSheet;
{
  NSWindowController *controller = self.windowControllers[0];
  [controller.window beginSheet:self.progressWindow
              completionHandler:^(NSModalResponse returnCode) {
    if (returnCode == NSModalResponseAbort) {
      [self.task interrupt];
    }
    // Reset the sheet /after/ it has been removed from screen.
    dispatch_async(dispatch_get_main_queue(), ^{
      [self resetSheet];
    });
  }];
}

- (IBAction)dismissProgressSheet:(id)sender;
{
  NSWindowController *controller = self.windowControllers[0];
  [controller.window endSheet:self.progressWindow
                   returnCode:(self.task.isRunning ?
                                NSModalResponseAbort : NSModalResponseStop)];
}

- (void)resetSheet;
{
  self.progressOutputView.string = @"";
}

#pragma mark -
#pragma mark Command execution

- (IBAction)updatePods:(id)sender;
{
  [self taskWithCommand:@"update"];
}

- (IBAction)installPods:(id)sender;
{
  [self taskWithCommand:@"install"];
}

- (void)taskWithCommand:(NSString *)command;
{
  if (self.isDocumentEdited) {
    [self saveDocument:nil];
  }

  NSArray *arguments = @[@"pod", command, @"--ansi"];
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"CPShowVerboseCommandOutput"]) {
    arguments = [arguments arrayByAddingObject:@"--verbose"];
  }

  self.task = [NSTask new];
  self.task.launchPath = [[NSBundle mainBundle] pathForResource:@"bundle-env" ofType:nil inDirectory:@"bundle/bin"];
  self.task.arguments = arguments;
  self.task.environment = @{ @"HOME":NSHomeDirectory(), @"TERM":@"xterm-256color" };
  self.task.currentDirectoryPath = [[self.fileURL URLByDeletingLastPathComponent] path];
  NSLog(@"(PWD: %@ - ENV: %@) %@ %@", self.task.currentDirectoryPath, self.task.environment, self.task.launchPath, [self.task.arguments componentsJoinedByString:@" "]);

  NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

  NSPipe *outputPipe = [NSPipe pipe];
  self.task.standardOutput = outputPipe;
  [nc addObserver:self
         selector:@selector(outputAvailable:)
             name:NSFileHandleDataAvailableNotification
           object:[outputPipe fileHandleForReading]];
  [[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];

  NSPipe *errorPipe = [NSPipe pipe];
  self.task.standardError = errorPipe;
  [nc addObserver:self
         selector:@selector(outputAvailable:)
             name:NSFileHandleDataAvailableNotification
           object:[errorPipe fileHandleForReading]];
  [[errorPipe fileHandleForReading] waitForDataInBackgroundAndNotify];

  [self.task launch];

  [self presentProgressSheet];
}

- (void)outputAvailable:(NSNotification *)notification;
{
  NSFileHandle *fileHandle = notification.object;
  NSData *data = fileHandle.availableData;

  if (data.length > 0) {
    NSString *output = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    // NSPipe *outputPipe = self.task.standardOutput;
    // BOOL standardOutput = fileHandle == outputPipe.fileHandleForReading;
    // NSLog(@"[%@] %@", standardOutput ? @"STDOUT" : @"STDERR", output);
    self.progressOutputView.string = [self.progressOutputView.string stringByAppendingString:output];
  }

  if (self.task.isRunning) {
    [fileHandle waitForDataInBackgroundAndNotify];
  } else {
    // Setting to `nil` signals through bindings that task has finished.
    self.task = nil;
  }
}

@end
