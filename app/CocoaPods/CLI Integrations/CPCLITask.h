#import <Foundation/Foundation.h>

@class CPCLITask;
@protocol CPCLITaskDelegate <NSObject>

@optional
/**
 * Called when output is received and appended to the task's log.
 *
 * @param task The task object receiving the output
 * @param updatedOutput The string which contains all of the output for this task, including the newest appended part.
 */
- (void)task:(CPCLITask *)task didUpdateOutputContents:(NSAttributedString *)updatedOutput;

/**
 * Called when the task is completed.
 *
 * @param task The task object receiving the output
 */
- (void)taskCompleted:(CPCLITask *)task;

@end

@class CPUserProject;

/**
 * Represents a task performed on the command line utilizing
 */
@interface CPCLITask : NSObject <NSProgressReporting>

/**
 * @param userProject The project/directory for which the command should be performed.
 * @param command The `pod` command to execute, such as `install` or `update.`
 */
- (instancetype)initWithUserProject:(CPUserProject *)userProject
                            command:(NSString *)command
                          arguments:(NSArray *)arguments
                           delegate:(id<CPCLITaskDelegate>)delegate
                   qualityOfService:(NSQualityOfService)qualityOfService;

/**
 * @param workingDirectory The directory for which the command should be performed.
 * @param command The `pod` command to execute, such as `install` or `update.`
 */
- (instancetype)initWithWorkingDirectory:(NSString *)workingDirectory
                                 command:(NSString *)command
                               arguments:(NSArray *)arguments
                                delegate:(id<CPCLITaskDelegate>)delegate
                        qualityOfService:(NSQualityOfService)qualityOfService;

/**
 * Perform the task.
 */
- (void)run;

/**
 * Cancels the task and invalidates the progress object.
 */
- (void)cancel;

/// Is the command currently running, KVO compliant
@property (nonatomic, readonly) BOOL running;

/// Appends `--ansi` to the end of the command, defaults to NO
@property (nonatomic, assign) BOOL colouriseOutput;

/// Appends `--verbose` to the end of the command, defaults to NO
@property (nonatomic, assign) BOOL verboseOutput;

/// If the task is done and successful, returns YES, otherwise NO
- (BOOL)finishedSuccessfully;

@end
