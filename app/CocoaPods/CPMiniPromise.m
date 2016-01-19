#import "CPMiniPromise.h"

@interface CPMiniPromise()
@property (strong) NSMutableArray *completionBlocks;
@end

@implementation CPMiniPromise

+ (CPMiniPromise *)promiseWithDelegate:(id <CPMiniPromiseDelegate> )delegate
{
  CPMiniPromise *promise = [[CPMiniPromise alloc] init];
  promise.delegate = delegate;
  return promise;
}

- (void)checkForFulfillment
{
  if ([self shouldSendCompletionBlocks] == NO) { return; }
  [self sendAllCompletions];
}

- (BOOL)shouldSendCompletionBlocks
{
  return [self.delegate shouldFulfillPromise:self];
}

- (void)addBlock:(void (^)(void))block
{
  id ourBlock = [block copy];
  self.completionBlocks = self.completionBlocks ?: [NSMutableArray array];

  [self.completionBlocks addObject:ourBlock];
  [self checkForFulfillment];
}

- (void)sendAllCompletions
{
  for (void (^completion)(void) in self.completionBlocks) {
    completion();
  }
  [self.completionBlocks removeAllObjects];
}

@end
