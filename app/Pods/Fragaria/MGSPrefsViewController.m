//
//  MGSPrefsViewController.m
//  Fragaria
//
//  Created by Jim Derry on 3/15/15.
//
//

#import "MGSPrefsViewController.h"
#import "MGSFragariaView+Definitions.h"
#import "MGSUserDefaultsControllerProtocol.h"
#import "MGSUserDefaultsController.h"


#pragma mark - Proxy Classes

/*
 *  This bindable proxy object exists to support the managedProperties 
 *  property, whereby we return a @(BOOL) indicating whether or not the
 *  view controller's NSUserDefaultsController is managing the property
 *  in the keypath, e.g., `viewController.managedProperties.textColour`.
 */
@interface MGSManagedPropertiesProxy : NSObject

@property (nonatomic, weak) id <MGSUserDefaultsController> userDefaultsController;
@property (nonatomic, weak) MGSPrefsViewController *viewController;

@end


@implementation MGSManagedPropertiesProxy

/*
 * - init
 */
- (instancetype)initWithViewController:(MGSPrefsViewController *)viewController
{
    if ((self = [super init]))
    {
        self.viewController = viewController;
    }

    return self;
}


/*
 * - valueForKey
 */
-(id)valueForKey:(NSString *)key
{
    BOOL managesProperty = [self.userDefaultsController.managedProperties containsObject:key];

    return @(managesProperty);
}

@end


/*
 *  This bindable proxy object exists to support the managedGlobalProperties
 *  property, whereby we return a @(BOOL) indicating whether or not the view
 *  controller's NSUserDefaultsController is managing the property in the
 *  keypath, e.g., `viewController.managedProperties.textColour`. This may
 *  be useful in UI applications that which to provide different styles for
 *  global versus group properties.
 */
@interface MGSManagedGlobalPropertiesProxy : MGSManagedPropertiesProxy


@end


@implementation MGSManagedGlobalPropertiesProxy
/*
 * - valueForKey
 */
-(id)valueForKey:(NSString *)key
{
	BOOL isGlobalProperty = [[[MGSUserDefaultsController sharedController] managedProperties] containsObject:key];
	
	return @(isGlobalProperty);
}
@end


#pragma mark - MGSPrefsViewController

@interface MGSPrefsViewController ()

@property IBOutlet NSView *nothingPane;
@property (nonatomic, strong) MGSManagedPropertiesProxy *managedPropertiesProxy;
@property (nonatomic, strong) MGSManagedGlobalPropertiesProxy *managedGlobalPropertiesProxy;

@end


@implementation MGSPrefsViewController {
    BOOL subviewsNeedUpdate;
    NSMutableArray *separators;
}


#pragma mark - Initialization

/*
 * - initWithNibName:bundle:
 */
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSBundle *bundle;
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;
    
    bundle = [NSBundle bundleForClass:[MGSPrefsViewController class]];
    [bundle loadNibNamed:@"MGSPrefsCommonViews" owner:self topLevelObjects:nil];
    
    _managedPropertiesProxy = [[MGSManagedPropertiesProxy alloc] initWithViewController:self];
	_managedGlobalPropertiesProxy = [[MGSManagedGlobalPropertiesProxy alloc] initWithViewController:self];
    
    _userDefaultsController = [MGSUserDefaultsController sharedController];
    self.managedPropertiesProxy.userDefaultsController = _userDefaultsController;
    self.managedGlobalPropertiesProxy.userDefaultsController = _userDefaultsController;
    subviewsNeedUpdate = YES;
    
    separators = [[NSMutableArray alloc] init];

    return self;
}


- (instancetype)init
{
    self = [super init];
    [self setView:[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 500, 0)]];
    return self;
}


#pragma mark - Property Accessors


- (NSView *)view
{
    if (subviewsNeedUpdate) {
        subviewsNeedUpdate = NO;
        [self showOrHideViews];
    }
    return [super view];
}


/*
 *  @property setUserDefaultsController
 */
- (void)setUserDefaultsController:(id <MGSUserDefaultsController>)userDefaultsController
{
    [self willChangeValueForKey:@"managedProperties"];
    _userDefaultsController = userDefaultsController;
    self.managedPropertiesProxy.userDefaultsController = userDefaultsController;
	self.managedGlobalPropertiesProxy.userDefaultsController = userDefaultsController;
    [self didChangeValueForKey:@"managedProperties"];
    subviewsNeedUpdate = YES;
}


/*
 * @property managedProperties
 */
- (id)managedProperties
{
    return self.managedPropertiesProxy;
}

/*
 * @property managedGlobalProperties
 */
+ (NSSet *)keyPathsForValuesAffectingManagedGlobalProperties
{
	return [NSSet setWithArray:@[ NSStringFromSelector(@selector(stylizeGlobalProperties)) ]];
}
- (id)managedGlobalProperties
{
	return self.stylizeGlobalProperties ? self.managedGlobalPropertiesProxy : nil;
}


/*
 * @property areAllColourPropertiesAvailable
 */
+ (NSSet *)keyPathsForValuesAffectingAreAllColourPropertiesAvailable
{
	return [NSSet setWithArray:@[ @"managedProperties" ]];
}
- (BOOL)areAllColourPropertiesAvailable
{
	NSSet *propertiesAvailable = self.userDefaultsController.managedProperties;
	NSSet *propertiesRequired = [MGSFragariaView propertyGroupTheme];
	return [propertiesRequired isSubsetOfSet:propertiesAvailable];
}


/*
 * @property hidesUselessPanels
 */
- (void)setHidesUselessPanels:(BOOL)hidesUselessPanels
{
	_hidesUselessPanels = hidesUselessPanels;
	[self showOrHideViews];
}


/*
 * @property toolbarItemImage
 */
- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNameAdvanced];
}


/*
 * @property identifier
 */
- (NSString *)identifier
{
    return NSStringFromClass([self class]);;
}


/*
 * @property toolbarItemLabel
 */
- (NSString *)toolbarItemLabel
{
    return [self identifier];
}


#pragma mark - Instance Methods

/*
 * - propertiesForPanelSubviews
 *   Subclasses wishing to support automatic view hiding should override this.
 *   See the reference implementation for an example of the dictionary format.
 */
- (NSDictionary *)propertiesForPanelSubviews
{
	return @{};
}


/*
 * - keysForPanelSubviews
 */
- (NSArray *)keysForPanelSubviews
{
    return @[];
}


#pragma mark - Supporting Methods


/*
 * - showOrHideViews
 *
 *   When this method is called, our userDefaultsController might not have been
 * assigned yet, and so we don't know which properties each panel is going to
 * manage.
 */
- (void)showOrHideViews
{
	NSSet *propertiesAvailable = self.userDefaultsController.managedProperties;
    NSArray *allViewsKeys, *cs;
    NSView *sep, *prev;
    BOOL hidden, anyVisible = NO;
    
    [self.view removeConstraints:[self.view constraints]];
    for (sep in separators) {
        [sep removeFromSuperview];
    }
    [separators removeAllObjects];
	
    allViewsKeys = [self keysForPanelSubviews];
	for (NSString *key in allViewsKeys) {
        NSView *thisView = [self valueForKey:key];
		NSSet *propertiesRequired = [[self propertiesForPanelSubviews] objectForKey:key];
        hidden = propertiesRequired && ![propertiesAvailable intersectsSet:propertiesRequired];
        anyVisible = anyVisible || !hidden;
		
		if (self.hidesUselessPanels && hidden) {
            [self hidePanelView:thisView];
		} else {
            [self stackPanelView:thisView underPanelView:prev];
            prev = thisView;
		}
	}
    
    if (!anyVisible) {
        [self stackPanelView:_nothingPane underPanelView:prev];
        prev = _nothingPane;
    }
    if (prev) {
        cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]|" options:0
          metrics:nil views:NSDictionaryOfVariableBindings(prev)];
        [self.view addConstraints:cs];
    }
    
    /* This is needed to update the view's height, because the preference
     * window handler will cache it before the first display. */
    [self.view layoutSubtreeIfNeeded];
}


/*
 * - stackPanelView:
 */
- (void)stackPanelView:(NSView *)view underPanelView:(NSView *)prev
{
    NSArray *cs;
    NSBox *newsep;
    
    if (![view superview]) {
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.view addSubview:view];
    }
    
    cs = [NSLayoutConstraint constraintsWithVisualFormat:@"|[view]|" options:0
      metrics:nil views:NSDictionaryOfVariableBindings(view)];
    [self.view addConstraints:cs];
    
    if (prev) {
        newsep = [[NSBox alloc] init];
        [newsep setTranslatesAutoresizingMaskIntoConstraints:NO];
        [newsep setBoxType:NSBoxSeparator];
        [self.view addSubview:newsep];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:@"|[newsep]|"
          options:0 metrics:nil views:NSDictionaryOfVariableBindings(newsep)];
        [self.view addConstraints:cs];
        cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[newsep(==1)]"
          options:0 metrics:nil views:NSDictionaryOfVariableBindings(newsep)];
        [self.view addConstraints:cs];
        [separators addObject:newsep];
        
        cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[prev]-0-[newsep]"
          options:0 metrics:nil views:NSDictionaryOfVariableBindings(prev, newsep)];
        [self.view addConstraints:cs];
        
        cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[newsep]-0-[view]"
          options:0 metrics:nil views:NSDictionaryOfVariableBindings(newsep, view)];
    } else {
        cs = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]"
          options:0 metrics:nil views:NSDictionaryOfVariableBindings(view)];
    }
    [self.view addConstraints:cs];
}


/*
 * - hidePanelView:
 */
- (void)hidePanelView:(NSView*)view
{
    if ([view superview])
        [view removeFromSuperviewWithoutNeedingDisplay];
}


@end
