/*
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria

 Smultron version 3.6b1, 2009-09-12
 Written by Peter Borg, pgw3@mac.com
 Find the latest version at http://smultron.sourceforge.net

 Copyright 2004-2009 Peter Borg

 Licensed under the Apache License, Version 2.0 (the "License"); you may not use
 this file except in compliance with the License. You may obtain a copy of the
 License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software distributed
 under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 CONDITIONS OF ANY KIND, either express or implied. See the License for the
 specific language governing permissions and limitations under the License.
 */

#import "MGSSyntaxController.h"


NSString * const KMGSSyntaxDefinitions =  @"SyntaxDefinitions";
NSString * const KMGSSyntaxDefinitionsExt = @"plist";
NSString * const kMGSSyntaxDefinitionsFile = @"SyntaxDefinitions.plist";
NSString * const KMGSSyntaxDictionaryExt = @"plist";
NSString * const KMGSSyntaxDefinitionsFolder = @"Syntax Definitions";


#pragma mark - Class Extension

@interface MGSSyntaxController()

@property (strong) NSMutableDictionary *syntaxDefinitions;

@end


#pragma mark - Implementation

@implementation MGSSyntaxController

static id sharedInstance = nil;


/*
 * + sharedInstance
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] _init];
    });
	
	return sharedInstance;
} 


/*
 * + standardSyntaxDefinitionName
 */
+ (NSString *)standardSyntaxDefinitionName
{
	return @"Standard";
}


/*
 * - init
 */
- (id)_init
{
    self = [super init];
        
    if (self) {
        [self insertSyntaxDefinitions];
    }
    return self;
}


- (instancetype)init
{
    return [[self class] sharedInstance];
}


/*
 *- standardSyntaxDefinition
 */
- (NSDictionary *)standardSyntaxDefinition
{
	// key is lowercase name
	NSString *name = [[self class] standardSyntaxDefinitionName];
	NSDictionary *definition = [self.syntaxDefinitions objectForKey:[name lowercaseString]];
	NSAssert(definition, @"standard syntax definition not found");
	return definition;
}


/*
 * - syntaxDefinitionWithName:
 */
- (NSDictionary *)syntaxDefinitionWithName:(NSString *)name
{
	// key is lowercase name
	NSDictionary *definition = [self.syntaxDefinitions objectForKey:[name lowercaseString]];
	if (!definition) {
		definition = [self standardSyntaxDefinition];
	}
	
	return definition;
}


/*
 * - syntaxDefinitionNameWithExtension
 */
- (NSString *)syntaxDefinitionNameWithExtension:(NSString *)extension
{
	NSString *name = nil;
	NSDictionary *definition = [self syntaxDefinitionWithExtension:extension];
	if (definition) {
		name = [definition valueForKey:@"name"];
	}
	
	return name;
}


/*
 * - syntaxDefinitionWithExtension
 */
- (NSDictionary *)syntaxDefinitionWithExtension:(NSString *)extension
{
	NSDictionary *definition = nil;
	
	extension = [extension lowercaseString];
	
	for (id item in self.syntaxDefinitions) {
		NSString *extensions = [self.syntaxDefinitions[item] valueForKey:@"extensions"];
		
		if (!extensions || [extensions isEqualToString:@""]) {
			continue;
		}
		
		NSMutableString *extensionsString = [NSMutableString stringWithString:extensions];
		[extensionsString replaceOccurrencesOfString:@"." withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [extensionsString length])];
		if ([[extensionsString componentsSeparatedByString:@" "] containsObject:extension]) {
			definition = self.syntaxDefinitions[item];
			break;
		}

	}
	
	return definition;
}


/*
 * - guessSyntaxDefinitionExtensionFromFirstLine:
 */
- (NSString *)guessSyntaxDefinitionExtensionFromFirstLine:(NSString *)firstLine
{
    NSString *returnString = nil;
    NSRange firstLineRange = NSMakeRange(0, [firstLine length]);
    if ([firstLine rangeOfString:@"perl" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"pl";
    } else if ([firstLine rangeOfString:@"wish" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"tcl";
    } else if ([firstLine rangeOfString:@"sh" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"sh";
    } else if ([firstLine rangeOfString:@"php" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"php";
    } else if ([firstLine rangeOfString:@"python" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"py";
    } else if ([firstLine rangeOfString:@"awk" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"awk";
    } else if ([firstLine rangeOfString:@"xml" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"xml";
    } else if ([firstLine rangeOfString:@"ruby" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"rb";
    } else if ([firstLine rangeOfString:@"%!ps" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"ps";
    } else if ([firstLine rangeOfString:@"%pdf" options:NSCaseInsensitiveSearch range:firstLineRange].location != NSNotFound) {
        returnString = @"pdf";
    }
    
    return returnString;
}


/*
 * - insertSyntaxDefinitions
 */
- (void)insertSyntaxDefinitions
{
	
	// load definitions
	NSMutableArray *syntaxDefinitionsArray = [self loadSyntaxDefinitions];
	
	// add Standard and None definitions
	NSArray *keys = [NSArray arrayWithObjects:@"name", @"file", @"extensions", nil];
	NSDictionary *standard = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Standard", @"standard", [NSString string], nil] forKeys:keys];
	NSDictionary *none = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"None", @"none", [NSString string], nil] forKeys:keys];
	[syntaxDefinitionsArray insertObject:none atIndex:0];
	[syntaxDefinitionsArray insertObject:standard atIndex:0];
		
	/*
	 build a dictionary of definitions keyed by lowercase definition name
	 */
	self.syntaxDefinitions = [NSMutableDictionary dictionaryWithCapacity:30];
	NSMutableArray *definitionNames = [NSMutableArray arrayWithCapacity:30];
	
	NSInteger idx = 0;
	for (id item in syntaxDefinitionsArray) {
		
		if ([[item valueForKey:@"extensions"] isKindOfClass:[NSArray class]]) { // If extensions is an array instead of a string, i.e. an older version
			continue;
		}

		NSString *name = [item valueForKey:@"name"];

		id syntaxDefinition = [NSMutableDictionary dictionaryWithCapacity:6];
		[syntaxDefinition setValue:name forKey:@"name"];
		[syntaxDefinition setValue:[item valueForKey:@"file"] forKey:@"file"];
		[syntaxDefinition setValue:[NSNumber numberWithInteger:idx] forKey:@"sortOrder"];
		[syntaxDefinition setValue:[item valueForKey:@"extensions"] forKey:@"extensions"];
		idx++;
		
		// key is lowercase name
		[self.syntaxDefinitions setObject:syntaxDefinition forKey:[name lowercaseString]];
		[definitionNames addObject:name];
	}
	
	_syntaxDefinitionNames = [definitionNames copy];

}


/*
 * - bundle
 */
- (NSBundle *)bundle
{
	NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];

	return frameworkBundle;
}


/*
 * - loadSyntaxDefinitions
 */
- (NSMutableArray *)loadSyntaxDefinitions
{
	NSMutableArray *syntaxDefinitionsArray = [NSMutableArray arrayWithCapacity:30];
											  
	// load syntax definitions from this bundle
	NSString *path = [[self bundle] pathForResource:KMGSSyntaxDefinitions ofType:KMGSSyntaxDefinitionsExt];
	NSAssert(path, @"framework syntax definitions not found");	
	[self addSyntaxDefinitions:syntaxDefinitionsArray path:path];
	
	// load syntax definitions from app bundle
	path = [[NSBundle mainBundle] pathForResource:KMGSSyntaxDefinitions ofType:KMGSSyntaxDefinitionsExt];
	[self addSyntaxDefinitions:syntaxDefinitionsArray path:path];
	
	// load syntax definitions from application support
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
	path = [[[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Application Support"] stringByAppendingPathComponent:appName] stringByAppendingPathComponent:kMGSSyntaxDefinitionsFile];
	[self addSyntaxDefinitions:syntaxDefinitionsArray path:path];
	
	return syntaxDefinitionsArray;
}


/*
 * - syntaxDictionaryWithName:
 */
- (NSDictionary *)syntaxDictionaryWithName:(NSString *)name
{
	if (!name) {
		name = [[self class] standardSyntaxDefinitionName];
	}
	
	NSDictionary *definition = [self syntaxDefinitionWithName:name];
	
	for (NSInteger i = 0; i <= 1; i++) {
		NSString *fileName = [definition objectForKey:@"file"];
		
		// load dictionary from this bundle
		NSDictionary *syntaxDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[self bundle] pathForResource:fileName ofType:KMGSSyntaxDefinitionsExt inDirectory:KMGSSyntaxDefinitionsFolder]];
		if (syntaxDictionary) return syntaxDictionary;
		
		// load dictionary from main bundle
		syntaxDictionary = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:KMGSSyntaxDefinitionsExt inDirectory:KMGSSyntaxDefinitionsFolder]];
		if (syntaxDictionary) return syntaxDictionary;
		
		// load from application support
		NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
		NSString *path = [[[[[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"Application Support"] stringByAppendingPathComponent:appName] stringByAppendingPathComponent:fileName] stringByAppendingString:KMGSSyntaxDictionaryExt];
		syntaxDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
		if (syntaxDictionary) return syntaxDictionary;
		
		// no dictionary found so use standard definition
		definition = [self standardSyntaxDefinition];
	}
	
	return nil;
}


/*
 * - addSyntaxDefinitions:path:
 */
- (void)addSyntaxDefinitions:(NSMutableArray *)definitions path:(NSString *)path
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:path] == YES) {
		[definitions addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:path]];
	}
	
}


@end
