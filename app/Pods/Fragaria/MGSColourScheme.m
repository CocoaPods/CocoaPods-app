//
//  MGSColourScheme.m
//  Fragaria
//
//  Created by Jim Derry on 3/16/15.
//
//

#import "MGSColourScheme.h"
#import "MGSFragariaView+Definitions.h"
#import "MGSColourToPlainTextTransformer.h"
#import "NSColor+TransformedCompare.h"


@interface MGSColourScheme ()

@property (nonatomic, assign, readwrite) NSDictionary *dictionaryRepresentation;
@property (nonatomic, assign, readwrite) NSDictionary *propertyListRepresentation;

+ (NSSet *) propertiesAll;
+ (NSSet *) propertiesOfTypeBool;
+ (NSSet *) propertiesOfTypeColor;
+ (NSSet *) propertiesOfTypeString;

@end

@implementation MGSColourScheme


#pragma mark - Initializers


/*
 * - initWithDictionary:
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
{
    if ((self = [self init]))
    {
        [self setDefaults];
        self.dictionaryRepresentation = dictionary;
    }

    return self;
}


/*
 * - initWithFile:
 */
- (instancetype)initWithFile:(NSString *)file
{
    if ((self = [self init]))
    {
        [self setDefaults];
        [self propertiesLoadFromFile:file];
    }

    return self;
}


/*
 * - init
 */
- (instancetype)init
{
	if ((self = [super init]))
	{
		[self setDefaults];
	}
	
	return self;
}


#pragma mark - General Properties


/*
 * @property dictionaryRepresentation
 * Publicly this is readonly, but we'll use the setter of this "representation"
 * internally in order to set the values from a dictionary.
 */
- (void)setDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation
{
    [self setValuesForKeysWithDictionary:dictionaryRepresentation];
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryWithValuesForKeys:[[[self class] propertiesAll] allObjects]];
}


/*
 * @property propertyListRepresentation
 * Publicly this is readonly, but we'll use the setter of this "representation"
 * internally in order to set the values from a property list.
 */
- (void)setPropertyListRepresentation:(NSDictionary *)propertyListRepresentation
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	NSValueTransformer *xformer = [NSValueTransformer valueTransformerForName:@"MGSColourToPlainTextTransformer"];

    for (NSString *key in [propertyListRepresentation allKeys])
    {
        if ([[[self class] propertiesOfTypeString] containsObject:key])
        {
			NSString *object = [propertyListRepresentation objectForKey:key];
            [dictionary setObject:object forKey:key];
        }
        if ([[[self class] propertiesOfTypeColor] containsObject:key])
        {
			NSColor *object = [xformer reverseTransformedValue:[propertyListRepresentation objectForKey:key]];
            [dictionary setObject:object forKey:key];
        }
        if ([[[self class] propertiesOfTypeBool] containsObject:key])
        {
			NSNumber *object = [propertyListRepresentation objectForKey:key];
            [dictionary setObject:object forKey:key];
        }
    }
    
    self.dictionaryRepresentation = dictionary;
}

- (NSDictionary *)propertyListRepresentation
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
	NSValueTransformer *xformer = [NSValueTransformer valueTransformerForName:@"MGSColourToPlainTextTransformer"];

    for (NSString *key in [self.dictionaryRepresentation allKeys])
    {
        if ([[[self class] propertiesOfTypeString] containsObject:key])
        {
            [dictionary setObject:[self.dictionaryRepresentation objectForKey:key] forKey:key];
        }
        if ([[[self class] propertiesOfTypeColor] containsObject:key])
        {
			[dictionary setObject:[xformer transformedValue:[self.dictionaryRepresentation objectForKey:key]] forKey:key];
        }
        if ([[[self class] propertiesOfTypeBool] containsObject:key])
        {
            [dictionary setObject:[self.dictionaryRepresentation objectForKey:key] forKey:key];
        }
    }
    
    return dictionary;
}


#pragma mark - Instance Methods


/*
 * - isEqualToScheme:
 */
- (BOOL)isEqualToScheme:(MGSColourScheme *)scheme
{
    for (NSString *key in [[self class] propertiesOfScheme])
    {
        if ([[self valueForKey:key] isKindOfClass:[NSColor class]])
        {
            NSColor *color1 = [self valueForKey:key];
            NSColor *color2 = [scheme valueForKey:key];
            BOOL result = [color1 mgs_isEqualToColor:color2 transformedThrough:@"MGSColourToPlainTextTransformer"];
            if (!result)
            {
//                NSLog(@"KEY=%@ and SELF=%@ and EXTERNAL=%@", key, color1, color2);
                return result;
            }
        }
        else
        {
            BOOL result = [[self valueForKey:key] isEqual:[scheme valueForKey:key]];
            if (!result)
            {
//                NSLog(@"KEY=%@ and SELF=%@ and EXTERNAL=%@", key, [self valueForKey:key], [scheme valueForKey:key] );
                return result;
            }
        }
    }

    return YES;
}


/*
 * - propertiesLoadFromFile:
 */
- (void)propertiesLoadFromFile:(NSString *)file
{
	file = [file stringByStandardizingPath];
	NSAssert([[NSFileManager defaultManager] fileExistsAtPath:file], @"File %@ not found!", file);
	
    NSDictionary *fileContents = [NSDictionary dictionaryWithContentsOfFile:file];
	NSAssert(fileContents, @"Error reading file %@", file);

    self.propertyListRepresentation = fileContents;
    self.sourceFile = file;
}


/*
 * - propertiesSaveToFile:
 */
- (BOOL)propertiesSaveToFile:(NSString *)file
{
    file = [file stringByStandardizingPath];
	NSDictionary *props = self.propertyListRepresentation;
	return [props writeToFile:file atomically:YES];
}


#pragma mark - Category and Private


/*
 * - setDefaults
 */
- (void)setDefaults
{
    // Use the built-in defaults instead of reinventing wheels.
    NSDictionary *defaults = [MGSFragariaView defaultsDictionary];

	self.loadedFromBundle = NO;
	
    self.displayName = NSLocalizedStringFromTableInBundle(@"Custom Settings", nil, [NSBundle bundleForClass:[self class]],  @"Name for Custom Settings scheme.");

    self.textColor = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsTextColor]];
    self.backgroundColor = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsBackgroundColor]];
    self.defaultSyntaxErrorHighlightingColour = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsDefaultErrorHighlightingColor]];

	self.textInvisibleCharactersColour = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsTextInvisibleCharactersColour]];
	self.currentLineHighlightColour = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsCurrentLineHighlightColour]];
	self.insertionPointColor = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsInsertionPointColor]];

    self.colourForAttributes = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsColourForAttributes]];
    self.colourForAutocomplete = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsColourForAutocomplete]];
    self.colourForCommands = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsColourForCommands]];
    self.colourForComments = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsColourForComments]];
    self.colourForInstructions = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsColourForInstructions]];
    self.colourForKeywords = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsColourForKeywords]];
    self.colourForNumbers = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsColourForNumbers]];
    self.colourForStrings = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsColourForStrings]];
    self.colourForVariables = [NSUnarchiver unarchiveObjectWithData:defaults[MGSFragariaDefaultsColourForVariables]];

    self.coloursAttributes = [defaults[MGSFragariaDefaultsColoursAttributes] boolValue];
    self.coloursAutocomplete = [defaults[MGSFragariaDefaultsColoursAutocomplete ] boolValue];
    self.coloursCommands = [defaults[MGSFragariaDefaultsColoursCommands] boolValue];
    self.coloursComments = [defaults[MGSFragariaDefaultsColoursComments] boolValue];
    self.coloursInstructions = [defaults[MGSFragariaDefaultsColoursInstructions] boolValue];
    self.coloursKeywords = [defaults[MGSFragariaDefaultsColoursKeywords] boolValue];
    self.coloursNumbers = [defaults[MGSFragariaDefaultsColoursNumbers] boolValue];
    self.coloursStrings = [defaults[MGSFragariaDefaultsColoursStrings] boolValue];
    self.coloursVariables = [defaults[MGSFragariaDefaultsColoursVariables] boolValue];
}


/*
 * + propertiesAll
 */
+ (NSSet *)propertiesAll
{
	return [[MGSFragariaView propertyGroupTheme]
			setByAddingObjectsFromSet:[[self class] propertiesOfTypeString]];
}


/*
 * + propertiesOfTypeBool
 */
+ (NSSet*)propertiesOfTypeBool
{
	return [MGSFragariaView propertyGroupSyntaxHighlightingBools];
}


/*
 * + propertiesOfTypeColor
 */
+ (NSSet *)propertiesOfTypeColor
{
	return [[MGSFragariaView propertyGroupEditorColours]
			setByAddingObjectsFromSet:[MGSFragariaView propertyGroupSyntaxHighlightingColours]];
}


/*
 * + propertiesOfTypeString
 */
+ (NSSet *)propertiesOfTypeString
{
	return [NSSet setWithArray:@[@"displayName"]];
}


/*
 * + colourProperties
 */
+ (NSArray *)propertiesOfScheme
{
	return [[MGSFragariaView propertyGroupTheme] allObjects];
}


@end
