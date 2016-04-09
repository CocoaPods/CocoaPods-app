#import <Foundation/Foundation.h>

@class CPMiniPromise;

/// Let another object decide the logic of whether to complete the promise
/// and run the blocks.

@protocol CPMiniPromiseDelegate <NSObject>
- (BOOL)shouldFulfillPromise:(CPMiniPromise *)promise;
@end


/// A simplified Promise class, it delegates the responsibility for
/// the logic of fulfillment. It will basically hold an array of
/// blocks and when completed, run them all only once.

@interface CPMiniPromise : NSObject

+ (CPMiniPromise *)promiseWithDelegate:(id <CPMiniPromiseDelegate> )delegate;

/// Object doing the logic
@property (nonatomic, weak) id <CPMiniPromiseDelegate> delegate;

/// So that external objects can say "somehting has changed:
- (void)checkForFulfillment;

/// Registering with the promise
- (void)addBlock:(void (^)(void))block;
@end
