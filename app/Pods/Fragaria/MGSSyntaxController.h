//
//  MGSSyntaxController.h
//  Fragaria
//
//  Created by Jonathan on 01/05/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MGSSyntaxController : NSObject {

	NSArray *syntaxDefinitionNames;
    NSMutableDictionary *syntaxDefinitions;
}

+ (instancetype)sharedInstance;
+ (NSString *)standardSyntaxDefinitionName;
- (NSArray *)syntaxDefinitionNames;
- (void)insertSyntaxDefinitions;
- (NSDictionary *)syntaxDictionaryWithName:(NSString *)name;
- (NSDictionary *)syntaxDefinitionWithExtension:(NSString *)extension;
- (NSString *)syntaxDefinitionNameWithExtension:(NSString *)extension;

@property (strong, nonatomic,readonly) NSArray *syntaxDefinitionNames;

@end
