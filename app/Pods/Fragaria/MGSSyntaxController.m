//
//  MGSSyntaxController.m
//  Fragaria
//
//  Created by Jonathan on 01/05/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//
/*
 Based on:
 
 Smultron version 3.6b1, 2009-09-12
 Written by Peter Borg, pgw3@mac.com
 Find the latest version at http://smultron.sourceforge.net
 
 Copyright 2004-2009 Peter Borg
 
 Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

 */
#import "MGSFragaria.h"
#import "MGSFragariaFramework.h"

NSString * const KMGSSyntaxDefinitions =  @"SyntaxDefinitions";
NSString * const KMGSSyntaxDefinitionsExt = @"plist";
NSString * const kMGSSyntaxDefinitionsFile = @"SyntaxDefinitions.plist";
NSString * const KMGSSyntaxDictionaryExt = @"plist";
NSString * const KMGSSyntaxDefinitionsFolder = @"Syntax Definitions";

// class extension
@interface MGSSyntaxController()
- (NSMutableArray *)loadSyntaxDefinitions;
- (void)addSyntaxDefinitions:(NSMutableArray *)definitions path:(NSString *)path;
- (NSDictionary *)standardSyntaxDefinition;
- (NSDictionary *)syntaxDefinitionWithName:(NSString *)name;
- (NSBundle *)bundle;

@property (strong, nonatomic, readwrite) NSArray *syntaxDefinitionNames;
@property (strong) NSMutableDictionary *syntaxDefinitions;

@end

@implementation MGSSyntaxController

@synthesize syntaxDefinitionNames;
@synthesize syntaxDefinitions;

static id sharedInstance = nil;

/*
 
 + sharedInstance
 
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
	
	return sharedInstance;
} 

/*
 
 + standardSyntaxDefinitionName
 
 */
+ (NSString *)standardSyntaxDefinitionName
{
	return @"Standard";
}

/*
 
 - init
 
 */
- (id)init 
{
    if (sharedInstance == nil) {
        self = [super init];
        
        if (self) {
            [self insertSyntaxDefinitions];
        }
	}
    
    return self;
}

/*
 
 - standardSyntaxDefinition
 
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
 
 - syntaxDefinitionWithName:
 
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
 
 - syntaxDefinitionNameWithExtension
 
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
 
 - syntaxDefinitionWithExtension
 
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
 
 - insertSyntaxDefinitions
 
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
	
	self.syntaxDefinitionNames = [definitionNames copy];

}

/*
 
 - bundle
 
 */
- (NSBundle *)bundle
{
	NSBundle *frameworkBundle = [NSBundle bundleForClass:[self class]];

	return frameworkBundle;
}
/*
 
 - loadSyntaxDefinitions
 
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
 
 - syntaxDictionaryWithName:
 
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
 
 - addSyntaxDefinitions:path:
 
 */
- (void)addSyntaxDefinitions:(NSMutableArray *)definitions path:(NSString *)path
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:path] == YES) {
		[definitions addObjectsFromArray:[[NSArray alloc] initWithContentsOfFile:path]];
	}
	
}


@end
