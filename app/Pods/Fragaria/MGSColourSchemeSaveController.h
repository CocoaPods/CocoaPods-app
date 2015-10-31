//
//  MGSColourSchemeSaveController.h
//  Fragaria
//
//  Created by Jim Derry on 3/21/15.
//
//

#import <Foundation/Foundation.h>

/**
 *  Provides a scheme naming service for MGSColourSchemeController, as well
 *  as a file deletion confirmation service.
 **/
@interface MGSColourSchemeSaveController : NSWindowController


/**
 *  The name of the scheme. You can retrieve this after showSchemeNameGetter
 *  returns.
 **/
@property (nonatomic, strong) NSString *schemeName;

/**
 *  The filename of the scheme. You can retrieve this after showSchemeNameGetter
 *  returns. The filename will be a slightly sanitized version of `schemeName`
 *  (to remove unwanted characters).
 **/
@property (nonatomic, strong) NSString *fileName;


/**
 *  Invokes the file name request sheet and returns the name of the
 *  scheme, using a block to capture the end. Returns YES if the user wants
 *  to save the file, or NO if the user cancels.
 *  @param window The window to which to attach the name picker.
 *  @param aCompletionBlock Something you want to do after the user picks a
 *  name or cancels.
 */
- (void)showSchemeNameGetter:(NSWindow *)window completion:(void (^)(BOOL))aCompletionBlock;

/**
 *  Invokes the deletion confirmation request sheet and returns YES if the
 *  user confirms, or NO if the user cancels.
 *  @param window The window to which to attach the sheet.
 *  @param aCompletionBlock Something you want to do after the user confirms.
 */
- (void)showDeleteConfirmation:(NSWindow *)window completion:(void (^)(BOOL))aCompletionBlock;

@end
