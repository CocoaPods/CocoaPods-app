//
//  MGSUserDefaultsController.m
//  Fragaria
//
//  Created by Jim Derry on 3/3/15.
//
//

#import "MGSMutableDictionary.h"
#import "MGSUserDefaultsController.h"
#import "MGSFragariaView+Definitions.h"
#import "MGSUserDefaults.h"
#import "MGSFragariaView.h"


/* This method exists only because Apple added +weakObjectsHashTable in 10.8,
 * but we still want to support 10.7 */
static NSHashTable *MGSWeakOrUnretainedHashTable(void)
{
    NSPointerFunctions *pf;
    
    if (NSAppKitVersionNumber < NSAppKitVersionNumber10_8) {
        /* 
         * NSPointerFunctionsOpaqueMemory is not reccommended for objects, but
         * the main thing we want here is that the hash table won't mess with
         * retaining and releasing the Fragarias we put in. Since Fragarias
         * are NSViews, we can also use NSPointerFunctionsObjectPointerPersonality
         * because it implements object equality and hashing like the default
         * implementation of NSObject, and views never override equality
         * and hashing methods. 
         */
        pf = [NSPointerFunctions pointerFunctionsWithOptions:
          NSPointerFunctionsObjectPointerPersonality |
          NSPointerFunctionsOpaqueMemory];
        return [[NSHashTable alloc] initWithPointerFunctions:pf capacity:0];
    }
    return [NSHashTable weakObjectsHashTable];
}


#pragma mark - CATEGORY MGSUserDefaultsController


@interface MGSUserDefaultsController ()

@property (nonatomic, strong, readwrite) id values;

@end


#pragma mark - CLASS MGSUserDefaultsController - Implementation


static NSMutableDictionary *controllerInstances;
static NSHashTable *allManagedInstances;
static NSCountedSet *allNonGlobalProperties;


@implementation MGSUserDefaultsController {
    NSHashTable *_managedInstances;
}


#pragma mark - Class Methods - Singleton Controllers


/*
 *  + sharedControllerForGroupID:
 */
+ (instancetype)sharedControllerForGroupID:(NSString *)groupID
{
    MGSUserDefaultsController *res;
    
    if (!groupID || [groupID length] == 0)
        groupID = MGSUSERDEFAULTS_GLOBAL_ID;

	@synchronized(self) {
        if (!controllerInstances)
            controllerInstances = [[NSMutableDictionary alloc] init];
        else if ((res = [controllerInstances objectForKey:groupID]))
			return res;
	
		res = [[[self class] alloc] initWithGroupID:groupID];
		[controllerInstances setObject:res forKey:groupID];
        
		return res;
	}
}


/*
 *  + sharedController
 */
+ (instancetype)sharedController
{
	return [[self class] sharedControllerForGroupID:MGSUSERDEFAULTS_GLOBAL_ID];
}


#pragma mark - Property Accessors


- (BOOL)isGlobal
{
    return [self.groupID isEqual:MGSUSERDEFAULTS_GLOBAL_ID];
}


/*
 *  @property managedInstances
 */
- (NSSet *)managedInstances
{
    return [NSSet setWithArray:[self.managedInstancesHashTable allObjects]];
}


- (NSHashTable *)managedInstancesHashTable
{
    if ([self isGlobal])
        return allManagedInstances;
    return _managedInstances;
}


/*
 * - addFragariaToManagedSet:
 */
- (void)addFragariaToManagedSet:(MGSFragariaView *)object
{
    MGSUserDefaultsController *shc;
    
    if (!allManagedInstances)
        allManagedInstances = MGSWeakOrUnretainedHashTable();
    if ([allManagedInstances containsObject:object])
        [NSException raise:@"MGSUserDefaultsControllerClash" format:@"Trying "
      "to manage Fragaria %@ with more than one MGSUserDefaultsController!", object];
    
    [self registerBindings:_managedProperties forFragaria:object];
    
    if (![self isGlobal]) {
        shc = [MGSUserDefaultsController sharedController];
        [shc registerBindings:shc.managedProperties forFragaria:object];
    }
    
    [_managedInstances addObject:object];
    [allManagedInstances addObject:object];
}


/*
 * - removeFragariaFromManagedSet:
 */
- (void)removeFragariaFromManagedSet:(MGSFragariaView *)object
{
    MGSUserDefaultsController *shc;
    
    if (![_managedInstances containsObject:object]) {
        NSLog(@"Attempted to remove Fragaria %@ from %@ but it was not "
              "registered in the first place!", object, self);
        return;
    }
    
    [self unregisterBindings:_managedProperties forFragaria:object];
    if (![self isGlobal]) {
        shc = [MGSUserDefaultsController sharedController];
        [shc unregisterBindings:shc.managedProperties forFragaria:object];
    }
    
    [_managedInstances removeObject:object];
    [allManagedInstances addObject:object];
}


/*
 *  @property managedProperties
 */
- (void)setManagedProperties:(NSSet *)new
{
    NSSet *old = _managedProperties;
    NSMutableSet *added, *removed, *diag, *glob;
    
    added = [new mutableCopy];
    [added minusSet:old];
    removed = [old mutableCopy];
    [removed minusSet:new];
    
    if ([self isGlobal]) {
        if ([allNonGlobalProperties intersectsSet:new]) {
            diag = [NSMutableSet setWithSet:allNonGlobalProperties];
            [diag intersectSet:new];
            [NSException raise:@"MGSUserDefaultsControllerPropertyClash" format:
             @"Tried to manage globally properties which are already managed "
             "locally.\nConflicting properties: %@", diag];
        }
    } else {
        if (!allNonGlobalProperties)
            allNonGlobalProperties = [NSCountedSet set];
        [allNonGlobalProperties minusSet:old];
        [allNonGlobalProperties unionSet:new];
        glob = [[[[self class] sharedController] managedProperties] mutableCopy];
        [glob minusSet:new];
        [[[self class] sharedController] setManagedProperties:glob];
    }
    
    [self unregisterBindings:removed];
    _managedProperties = new;
	[self registerBindings:added];
}


/*
 *  @property persistent
 */
- (void)setPersistent:(BOOL)persistent
{
    NSDictionary *defaultsDict, *currentDict, *defaultsValues;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSUserDefaultsController *udc = [NSUserDefaultsController sharedUserDefaultsController];
    NSString *groupKeyPath;
    
	if (_persistent == persistent) return;
    _persistent = persistent;

    groupKeyPath = [NSString stringWithFormat:@"values.%@", self.groupID];
	if (persistent) {
        defaultsDict = [self archiveForDefaultsDictionary:self.values];
        [ud setObject:defaultsDict forKey:self.groupID];
        
		[udc addObserver:self forKeyPath:groupKeyPath options:NSKeyValueObservingOptionNew context:nil];
	} else {
		[udc removeObserver:self forKeyPath:groupKeyPath context:nil];

        currentDict = [ud objectForKey:self.groupID];
        defaultsValues = [self unarchiveFromDefaultsDictionary:currentDict];
        for (NSString *key in self.values) {
            if (![[self.values valueForKey:key] isEqual:[defaultsValues valueForKey:key]])
                [self.values setValue:[defaultsValues valueForKey:key] forKey:key];
        }
	}
}


#pragma mark - Initializers (not exposed)

/*
 *  - initWithGroupID:
 */
- (instancetype)initWithGroupID:(NSString *)groupID
{
    NSDictionary *defaults;
    
	if (!(self = [super init]))
        return self;
    
    defaults = [MGSFragariaView defaultsDictionary];
    
    _groupID = groupID;
    if ([self isGlobal])
        _managedProperties = [NSSet setWithArray:[defaults allKeys]];
    else
        _managedProperties = [NSSet set];
    _managedInstances = MGSWeakOrUnretainedHashTable();
		
    [[MGSUserDefaults sharedUserDefaultsForGroupID:groupID] registerDefaults:defaults];
    defaults = [[NSUserDefaults standardUserDefaults] valueForKey:groupID];
    
    self.values = [[MGSMutableDictionary alloc] initWithController:self
      dictionary:[self unarchiveFromDefaultsDictionary:defaults]];
	
	return self;
}


/*
 *  - init
 *    Just in case someone tries to create their own instance
 *    of this class, we'll make sure it's always "Global".
 */
- (instancetype)init
{
	return [self initWithGroupID:MGSUSERDEFAULTS_GLOBAL_ID];
}


#pragma mark - Binding Registration/Unregistration and KVO Handling


/*
 *  - registerBindings
 */
- (void)registerBindings:(NSSet *)propertySet
{
    NSHashTable *fragarias = [self managedInstancesHashTable];
    for (MGSFragariaView *fragaria in fragarias)
        [self registerBindings:propertySet forFragaria:fragaria];
}


/*
 *  - registerBindings:forFragaria:
 */
- (void)registerBindings:(NSSet *)propertySet forFragaria:(MGSFragariaView *)fragaria
{
    for (NSString *key in propertySet) {
        [fragaria bind:key toObject:self.values withKeyPath:key options:nil];
    }
}


/*
 *  - unregisterBindings:
 */
- (void)unregisterBindings:(NSSet *)propertySet
{
    NSHashTable *fragarias = [self managedInstancesHashTable];
    for (MGSFragariaView *fragaria in fragarias)
        [self unregisterBindings:propertySet forFragaria:fragaria];
}


/*
 *  - unregisterBindings:forFragaria:
 */
- (void)unregisterBindings:(NSSet *)propertySet forFragaria:(MGSFragariaView *)fragaria
{
    for (NSString *key in propertySet) {
        [fragaria unbind:key];
    }
}


/*
 * - observeValueForKeyPath:ofObject:change:context:
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSDictionary *currentDict, *defaultsValues;
    
	// The only keypath we've registered, but let's check in case we accidentally something.
	if ([[NSString stringWithFormat:@"values.%@", self.groupID] isEqual:keyPath])
	{
        currentDict = [[NSUserDefaults standardUserDefaults] objectForKey:self.groupID];
        defaultsValues = [self unarchiveFromDefaultsDictionary:currentDict];
        
        for (NSString *key in defaultsValues) {
            // If we use self.value valueForKey: here, we will get the value from defaults.
            if (![[defaultsValues valueForKey:key] isEqual:[self.values objectForKey:key]])
                [self.values setValue:[defaultsValues valueForKey:key] forKey:key];
        }
	}
}


#pragma mark - Utilities


/*
 *  - unarchiveFromDefaultsDictionary:
 *    The fragariaDefaultsDictionary is meant to be written to userDefaults as
 *    is, but it's not good for internal storage, where we want real instances,
 *    and not archived data.
 */
- (NSDictionary *)unarchiveFromDefaultsDictionary:(NSDictionary *)source
{
    NSMutableDictionary *destination;
    
    destination = [NSMutableDictionary dictionaryWithCapacity:source.count];
    for (NSString *key in source) {
        id object = [source objectForKey:key];
        
        if ([object isKindOfClass:[NSData class]])
            object = [NSUnarchiver unarchiveObjectWithData:object];
        [destination setObject:object forKey:key];
    }

    return destination;
}


/*
 * - archiveForDefaultsDictionary:
 *   If we're copying things to user defaults, we have to make sure that any
 *   objects the requiring archiving are archived.
 */
- (NSDictionary *)archiveForDefaultsDictionary:(NSDictionary *)source
{
    NSMutableDictionary *destination;
    
    destination = [NSMutableDictionary dictionaryWithCapacity:source.count];
    for (NSString *key in source) {
        id object = [source objectForKey:key];
        
        if ([object isKindOfClass:[NSFont class]] || [object isKindOfClass:[NSColor class]])
            object = [NSArchiver archivedDataWithRootObject:object];
        [destination setObject:object forKey:key];
    }

    return destination;
}


@end
