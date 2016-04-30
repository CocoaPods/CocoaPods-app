//
//  NSSet+Fragaria.m
//  Fragaria
//
//  Created by Daniele Cattaneo on 06/03/16.
//
//

#import "NSSet+Fragaria.h"


@interface MGSSetBackedByIndexSet: NSSet

- (instancetype)initWithIndexSet:(NSIndexSet *)is;

- (NSUInteger)count;
- (id)member:(id)obj;
- (NSEnumerator *)objectEnumerator;

@end


@interface MGSSetBackedByIndexSetEnumerator : NSEnumerator

- (instancetype)initWithSet:(MGSSetBackedByIndexSet *)s;

- (NSArray *)allObjects;
- (id)nextObject;

@end


@implementation MGSSetBackedByIndexSet
{
    NSIndexSet *_backingStore;
}


- (instancetype)initWithIndexSet:(NSIndexSet *)is
{
    self = [super init];
    _backingStore = [is copy];
    return self;
}


- (NSUInteger)count
{
    return [_backingStore count];
}


- (id)member:(id)obj
{
    if (![obj isKindOfClass:[NSNumber class]])
        return nil;
    
    /* Lowercase objCTypes correspond to signed values. */
    if (islower([obj objCType][0])) {
        /* Bail out if negative */
        if ([obj compare:@(0)] == NSOrderedAscending)
            return nil;
    }
    
    if ([_backingStore containsIndex:[obj unsignedIntegerValue]])
        return obj;
    return nil;
}


- (NSEnumerator *)objectEnumerator
{
    return [[MGSSetBackedByIndexSetEnumerator alloc] initWithSet:self];
}


- (NSIndexSet *)_indexSet
{
    return _backingStore;
}


@end


@implementation MGSSetBackedByIndexSetEnumerator
{
    MGSSetBackedByIndexSet *_set;
    NSUInteger _nextIndex;
}


- (instancetype)initWithSet:(MGSSetBackedByIndexSet *)s
{
    self = [super init];
    _set = s;
    _nextIndex = 0;
    return self;
}


- (NSArray *)allObjects
{
    NSRange range;
    __block NSMutableArray *a;
    NSIndexSet *is = _set._indexSet;
    
    a = [NSMutableArray array];
    if (is.lastIndex != NSNotFound && is.lastIndex >= _nextIndex) {
        range = NSMakeRange(_nextIndex, (is.lastIndex+1) - _nextIndex);
        [is enumerateIndexesInRange:range options:0
          usingBlock:^(NSUInteger i, BOOL *stop) {
            [a addObject:@(i)];
        }];
    }
    _set = nil;
    return [a copy];
}


- (id)nextObject
{
    NSUInteger idx;
    
    idx = [_set._indexSet indexGreaterThanOrEqualToIndex:_nextIndex];
    if (idx == NSNotFound) {
        _set = nil;
        return nil;
    }
    _nextIndex = idx+1;
    return @(idx);
}


@end


@implementation NSSet (Fragaria)


- (NSSet *)mgs_initWithIndexSet:(NSIndexSet *)is
{
    return [[MGSSetBackedByIndexSet alloc] initWithIndexSet:is];
}


@end
