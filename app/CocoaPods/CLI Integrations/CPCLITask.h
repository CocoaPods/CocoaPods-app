#import <Foundation/Foundation.h>

@class CPCLITask;
@protocol CPCLITaskDelegate <NSObject>

/**
 * Called when output is received and appended to the task's log.
 *
 * @param task The task object receiving the output
 * @param updatedOutput The string which contains all of the output for this task, including the newest appended part.
 */
- (void)task:(CPCLITask *)task didUpdateOutputContents:(NSAttributedString *)updatedOutput;

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

@property (nonatomic, readonly) BOOL running;

@end
