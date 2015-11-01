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

#import <Cocoa/Cocoa.h>


/**
 *  Manages syntax definitions for Fragaria.
 *  @discussion Syntax definitions are found in the framework bundle by default,
 *  but can also be loaded automatically from your app bundle and from
 *  /Users/{user}/Library/Application Support/{appname}/.
 **/
@interface MGSSyntaxController : NSObject


/// @name Class Methods

/**
 *  Returns a shared instance of the MGSSyntaxController.
 **/
+ (instancetype)sharedInstance;

/**
 *  Returns the definition name for syntax "standard."
 **/
+ (NSString *)standardSyntaxDefinitionName;


/// @name Instance Methods

/**
 *  Constructs the array of all syntax definitions.
 **/
- (void)insertSyntaxDefinitions;

/**
 *  Returns a syntax dictionary for definition `name`.
 *  @param name The syntax definition name for which to return a dictionary.
 **/
- (NSDictionary *)syntaxDictionaryWithName:(NSString *)name;

/**
 *  Returns a syntax definition based on common file extensions.
 *  @param extension The file extension for which to return a dictionary.
 **/
- (NSDictionary *)syntaxDefinitionWithExtension:(NSString *)extension;

/**
 *  Return the name of a syntax definition for the given extension.
 *  @param extension The extension for which to return a syntax definition name.
 **/
- (NSString *)syntaxDefinitionNameWithExtension:(NSString *)extension;

/**
 *  Attempts to guess the syntax definition from the first line of text.
 *  @param firstLine The sample text to use in order to guess the syntax definition.
 **/
- (NSString *)guessSyntaxDefinitionExtensionFromFirstLine:(NSString *)firstLine;


/// @name Properties

/**
 *  Returns an array of all of the syntax definition names that are known.
 **/
@property (strong,nonatomic,readonly) NSArray *syntaxDefinitionNames;

@end
