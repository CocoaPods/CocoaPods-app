//
//  MGSHybridUserDefaultsController.m
//  Fragaria
//
//  Created by Jim Derry on 3/24/15.
//
//

#import "MGSHybridUserDefaultsController.h"
#import "MGSUserDefaultsController.h"


/*
 *  This bindable proxy object exists to support the managedProperties
 *  property, whereby we return a @(BOOL) indicating whether or not the
 *  view controller's NSUserDefaultsController is managing the property
 *  in the keypath, e.g., `viewController.managedProperties.textColour`.
 */
@interface MGSHybridValuesProxy : NSObject

@property (nonatomic, weak) MGSHybridUserDefaultsController *controller;

@end


@implementation MGSHybridValuesProxy


/*
 * - initWithController:
 */
- (instancetype)initWithController:(MGSHybridUserDefaultsController *)controller
{
    if ((self = [super init]))
    {
        self.controller = controller;
    }

    return self;
}

/*
 * - setValue:forKey:
 */
- (void)setValue:(id)value forKey:(NSString *)key
{
    MGSUserDefaultsController *group = [MGSUserDefaultsController sharedControllerForGroupID:self.controller.groupID];
    MGSUserDefaultsController *global = [MGSUserDefaultsController sharedController];

    if ([self.controller.managedProperties containsObject:key])
    {
        if ([group.managedProperties containsObject:key])
        {
            [group.values setValue:value forKey:key];
        }
        if ([global.managedProperties containsObject:key])
        {
            [global.values setValue:value forKey:key];
        }
        return;
    }

    [super setValue:value forKey:key];
}


/*
 * - valueForKey:
 */
- (id)valueForKey:(NSString *)key
{
    MGSUserDefaultsController *group = [MGSUserDefaultsController sharedControllerForGroupID:self.controller.groupID];
    MGSUserDefaultsController *global = [MGSUserDefaultsController sharedController];

    if ([self.controller.managedProperties containsObject:key])
    {
        if ([group.managedProperties containsObject:key])
        {
            return [group.values valueForKey:key];
        }
        if ([global.managedProperties containsObject:key])
        {
            return [global.values valueForKey:key];
        }
    }

    return [super valueForKey:key];
}


/*
 * - allKeys:
 */
- (NSArray *)allKeys
{
    return [self.controller.managedProperties allObjects];
}



@end


@implementation MGSHybridUserDefaultsController

#pragma mark - Class Methods - Singleton Controllers

/*
 *  + sharedControllerForGroupID:
 */
+ (instancetype)sharedControllerForGroupID:(NSString *)groupID
{
    static NSMutableDictionary *controllerInstances;

    NSAssert(groupID && [groupID length] > 0, @"groupID cannot be nil");

    @synchronized(self) {

        if (!controllerInstances)
        {
            controllerInstances = [[NSMutableDictionary alloc] init];
        }

        if ([[controllerInstances allKeys] containsObject:groupID])
        {
            return [controllerInstances objectForKey:groupID];
        }

        MGSHybridUserDefaultsController *newController = [[[self class] alloc] initWithGroupID:groupID];
        [controllerInstances setObject:newController forKey:groupID];
        return newController;
    }
}


#pragma mark - Initializers (not exposed)

/*
 *  - initWithGroupID:
 */
- (instancetype)initWithGroupID:(NSString *)groupID
{
    if ((self = [super init]))
    {
        _values = [[MGSHybridValuesProxy alloc] initWithController:self];
        _groupID = groupID;
    }
    
    return self;
}


#pragma mark - Protocol Conformance

/*
 * @property managedInstances
 */
- (NSSet *)managedInstances
{
    NSSet *groupSet = [[MGSUserDefaultsController sharedControllerForGroupID:self.groupID] managedInstances];
    NSSet *globalSet = [[MGSUserDefaultsController sharedController] managedInstances];
    return [groupSet setByAddingObjectsFromSet:globalSet];
}


/*
 * @property managedProperties
 */
- (NSSet *)managedProperties
{
    NSSet *groupSet = [[MGSUserDefaultsController sharedControllerForGroupID:self.groupID] managedProperties];
    NSSet *globalSet = [[MGSUserDefaultsController sharedController] managedProperties];
    return [groupSet setByAddingObjectsFromSet:globalSet];
}


@end
