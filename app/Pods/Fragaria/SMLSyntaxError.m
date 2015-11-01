//
//  SMLSyntaxError.m
//  Fragaria
//
//  Created by Viktor Lidholt on 4/9/13.
//
//

#import "SMLSyntaxError.h"


float const kMGSErrorCategoryAccess   =  50.0;
float const kMGSErrorCategoryConfig   = 150.0;
float const kMGSErrorCategoryDocument = 250.0;
float const kMGSErrorCategoryInfo     = 350.0;
float const kMGSErrorCategoryWarning  = 450.0;
float const kMGSErrorCategoryError    = 550.0;
float const kMGSErrorCategoryPanic    = 650.0;
float const kMGSErrorCategoryDefault  = 450.0;


@implementation SMLSyntaxError {
    BOOL manualImage;
}


#pragma mark - Class Methods


+ (NSImage *)defaultImageForWarningLevel:(float)level
{
    static NSArray *imageNames;
    static NSMutableDictionary *imageCache;
    static dispatch_once_t onceToken;
	NSString *imageName;
    NSInteger imageIdx;
    NSNumber *imageNum;
    NSImage *res;
    
    dispatch_once(&onceToken, ^{
        imageCache = [[NSMutableDictionary alloc] init];
        imageNames = @[@"messagesAccess", @"messagesConfig",
          @"messagesDocument", @"messagesInfo", @"messagesWarning",
          @"messagesError", @"messagesPanic"];
    });
    
    imageIdx = MIN(MAX(0, (NSInteger)(level/100.0)), 6);
    imageNum = @(imageIdx);
    
    if (!(res = [imageCache objectForKey:imageNum])) {
        imageName = [imageNames objectAtIndex:imageIdx];
        res = [[NSBundle bundleForClass:[self class]] imageForResource:imageName];
        [imageCache setObject:res forKey:imageNum];
    }

    return res;
}


+ (instancetype) errorWithDictionary:(NSDictionary *)dictionary
{
    return [[[self class] alloc] initWithDictionary:dictionary];
}


+ (instancetype)errorWithDescription:(NSString *)desc ofLevel:(float)level
  atLine:(NSUInteger)line
{
    SMLSyntaxError *res;
    
    res = [[SMLSyntaxError alloc] init];
    res.errorDescription = desc;
    res.line = line;
    res.warningLevel = level;
    return res;
}


#pragma mark - Instance Methods


- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if ((self = [self init])) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    
    manualImage = NO;
    self.line = 1;
    self.character = 1;
    self.warningLevel = kMGSErrorCategoryWarning;
    
    return self;
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"(description: \"%@\", line: %ld, "
      "column: %ld, length: %ld, level: %f)", self.errorDescription, self.line,
      self.character, self.length, self.warningLevel];
}


#pragma mark - Property Accessors


- (void)setWarningLevel:(float)warningLevel
{
    _warningLevel = warningLevel;
    if (!manualImage)
        _warningImage = [[self class] defaultImageForWarningLevel:warningLevel];
}


- (void)setWarningImage:(NSImage *)warningImage
{
    _warningImage = warningImage;
    manualImage = YES;
}


@end
