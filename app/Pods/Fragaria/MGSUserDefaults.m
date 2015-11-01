//
//  MGSUserDefaults.m
//  Fragaria
//
//  Created by Jim Derry on 3/3/15.
//
//

#import "MGSUserDefaults.h"


@implementation MGSUserDefaults


#pragma mark - Class Methods - Singletons


/*
 *  Provides a shared controller for `groupID`.
 *  @param groupID Indicates the identifier for this group
 *  of user defaults.
 */
+ (instancetype)sharedUserDefaultsForGroupID:(NSString *)groupID
{
	static NSMutableDictionary *instances;
	
	@synchronized(self) {

        if (!instances)
        {
            instances = [[NSMutableDictionary alloc] init];
        }

		if ([[instances allKeys] containsObject:groupID])
		{
			return [instances objectForKey:groupID];
		}
		
		MGSUserDefaults *newController = [[[self class] alloc] initWithGroupID:groupID];
		[instances setObject:newController forKey:groupID];
		return newController;
	}
}


/*
 *  Provides the shared controller for global defaults.
 */
+ (instancetype)sharedUserDefaults
{
	return [[self class] sharedUserDefaultsForGroupID:MGSUSERDEFAULTS_GLOBAL_ID];
}


#pragma mark - Instance Methods

/*
 *  - registerDefaults:
 */
- (void)registerDefaults:(NSDictionary *)registrationDictionary
{
    NSDictionary *groupDict = @{ self.groupID : registrationDictionary };
    [super registerDefaults:groupDict];
}


#pragma mark - Initializers


/*
 *  - initWithGroupID:
 */
- (instancetype)initWithGroupID:(NSString *)groupID
{
	if ((self = [super init]))
	{
		_groupID = groupID;
	}
	
	return self;	
}


/*
 *  - init
 *    Just in case someone tries to create an instance manually,
 *    force it to use the global defaults.
 */
- (instancetype)init
{
	return [self initWithGroupID:MGSUSERDEFAULTS_GLOBAL_ID];
}


#pragma mark - Other Overrides


/*
 *  - setObject:forKey
 *    All of the base class set*:forKey implement this.
 */
- (void)setObject:(id)value forKey:(NSString *)defaultName
{
	NSMutableDictionary *groupDict = [NSMutableDictionary dictionaryWithDictionary:[super objectForKey:self.groupID]];
	
	if (!groupDict)
	{
		groupDict = [[NSMutableDictionary alloc] init];
	}
	
	if (value)
	{
        if ([value isKindOfClass:[NSFont class]] || [value isKindOfClass:[NSColor class]])
        {
            [groupDict setObject:[NSArchiver archivedDataWithRootObject:value] forKey:defaultName];
        }
        else
        {
            [groupDict setObject:value forKey:defaultName];
        }
	}
	else
	{
		[groupDict removeObjectForKey:defaultName];
	}
	
	[super setObject:groupDict forKey:self.groupID];
}


/*
 *  - objectForKey:
 *    All of the base class *forKey: utilize this.
 */
- (id)objectForKey:(NSString *)defaultName
{
	NSDictionary *groupDict = [super objectForKey:self.groupID];
	
	if ([[groupDict allKeys] containsObject:defaultName])
	{
        id object = [groupDict valueForKey:defaultName];
        if ([object isKindOfClass:[NSData class]])
        {
            object = [NSUnarchiver unarchiveObjectWithData:object];
        }

        return object;
	}
	
	return nil;
}


#pragma mark - Private/Internal

@end
