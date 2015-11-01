//
//  MGSMutableDictionary.m
//  Fragaria
//
//  Created by Jim Derry on 3/14/15.
//
//

#import "MGSMutableDictionary.h"
#import "MGSUserDefaults.h"
#import "MGSUserDefaultsController.h"


@interface MGSMutableDictionary ()

@property (nonatomic, strong) NSMutableDictionary *storage;

@end


@implementation MGSMutableDictionary


#pragma mark - KVC

/*
 *  - setValue:forKey:
 */
- (void)setValue:(id)value forKey:(NSString *)key
{
    [self willChangeValueForKey:key];
    if (value)
    {
        [self setObject:value forKey:key];
    }
    else
    {
        [self removeObjectForKey:key];
    }
    
    if (self.controller.persistent)
    {
        [[MGSUserDefaults sharedUserDefaultsForGroupID:self.controller.groupID] setObject:value forKey:key];
    }
    [self didChangeValueForKey:key];
}


/*
 *  - valueForKey:
 */
- (id)valueForKey:(NSString *)key
{
    if (self.controller.persistent)
    {
        return [[MGSUserDefaults sharedUserDefaultsForGroupID:self.controller.groupID] objectForKey:key];
    }

    return [self objectForKey:key];
}


#pragma mark - Initializers


/*
 *  - initWithController:dictionary:capacity
 *    The pseudo-designated initializer for the subclass.
 */
- (instancetype)initWithController:(MGSUserDefaultsController *)controller dictionary:(NSDictionary *)dictionary capacity:(NSUInteger)numItems
{
    if ((self = [super init]))
    {
        if (dictionary)
        {
            self.storage = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        }
        else
        {
            self.storage = [[NSMutableDictionary alloc] initWithCapacity:numItems];
        }

        self.controller = controller;
    }

    return self;
}


/*
 *  - initWithController:dictionary:
 */
- (instancetype)initWithController:(MGSUserDefaultsController *)controller dictionary:(NSDictionary *)dictionary
{
    return [self initWithController:controller dictionary:dictionary capacity:1];
}


/*
 *  - init:
 */
- (instancetype)init
{
    return [self initWithController:nil dictionary:nil capacity:1];
}


/*
 *  - initWithCapacity:
 */
- (instancetype)initWithCapacity:(NSUInteger)numItems
{
    return [self initWithController:nil dictionary:nil capacity:numItems];
}


#pragma mark - Archiving


/*
 * + classForKeyedUnarchiver
 */
+ (Class)classForKeyedUnarchiver
{
    return [MGSMutableDictionary class];
}


/*
 * - classForKeyedArchiver
 */
- (Class)classForKeyedArchiver
{
    return [MGSMutableDictionary class];
}


#pragma mark - Internal Storage Wrapping


/*
 * - count
 */
- (NSUInteger)count
{
    return self.storage.count;
}


/*
 * - keyEnumerator
 */
- (NSEnumerator *)keyEnumerator
{
    return self.storage.keyEnumerator;
}


/*
 * - objectForKey:
 */
- (id)objectForKey:(id)aKey
{
    id object = [self.storage objectForKey:aKey];
    if ([object isKindOfClass:[NSData class]])
    {
        object = [NSUnarchiver unarchiveObjectWithData:object];
    }

    return object;
}


/*
 * - removeObjectForKey:
 */
- (void)removeObjectForKey:(id)aKey
{
    [self.storage removeObjectForKey:aKey];
}


/*
 * - setObject:forKey:
 */
- (void)setObject:(id)anObject forKey:(id)aKey
{
    if ([anObject isKindOfClass:[NSFont class]] || [anObject isKindOfClass:[NSColor class]])
    {
        [self.storage setObject:[NSArchiver archivedDataWithRootObject:anObject] forKey:aKey];
    }
    else
    {
        [self.storage setObject:anObject forKey:aKey];
    }
}


@end

