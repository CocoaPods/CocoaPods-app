//
//  SMLSyntaxError.h
//  Fragaria
//
//  Created by Viktor Lidholt on 4/9/13.
//
//

#import <Foundation/Foundation.h>

@interface SMLSyntaxError : NSObject
{
    NSString* description;
    int line;
    int character;
    NSString* code;
    int length;
    BOOL hideWarning;
  NSColor *customBackgroundColor;
}

@property (nonatomic,copy) NSString* description;
@property (nonatomic,assign) int line;
@property (nonatomic,assign) int character;
@property (nonatomic,copy) NSString* code;
@property (nonatomic,assign) int length;
@property (nonatomic,assign) BOOL hideWarning;
@property (nonatomic,copy) NSColor *customBackgroundColor;

@end
