#import "CPANSIEscapeHelper.h"
#import "CocoaPods-Swift.h"

@implementation CPANSIEscapeHelper

- (instancetype) init {
  self = [super init];
  if (!self) {
    return  nil;
  }
  
  CPFontAndColourGateKeeper *settings = [[CPFontAndColourGateKeeper alloc] init];

  self.font = [settings defaultFont];
  
  self.ansiColors[@(AMR_SGRCodeFgBlack)] = settings.cpBlack;
  self.ansiColors[@(AMR_SGRCodeFgRed)] = settings.cpRed;
  self.ansiColors[@(AMR_SGRCodeFgGreen)] = settings.cpGreen;
  self.ansiColors[@(AMR_SGRCodeFgYellow)] = settings.cpYellow;
  self.ansiColors[@(AMR_SGRCodeFgBlue)] = settings.cpBlack;
  self.ansiColors[@(AMR_SGRCodeFgMagenta)] = settings.cpMagenta;
  self.ansiColors[@(AMR_SGRCodeFgCyan)] = settings.cpCyan;
  self.ansiColors[@(AMR_SGRCodeFgWhite)] = settings.cpWhite;
  
  self.ansiColors[@(AMR_SGRCodeFgBrightBlack)] = settings.cpBrightBlack;
  self.ansiColors[@(AMR_SGRCodeFgBrightRed)] = settings.cpBrightRed;
  self.ansiColors[@(AMR_SGRCodeFgBrightGreen)] = settings.cpBrightGreen;
  self.ansiColors[@(AMR_SGRCodeFgBrightYellow)] = settings.cpBrightYellow;
  self.ansiColors[@(AMR_SGRCodeFgBrightBlue)] = settings.cpBrightBlue;
  self.ansiColors[@(AMR_SGRCodeFgBrightMagenta)] = settings.cpBrightMagenta;
  self.ansiColors[@(AMR_SGRCodeFgBrightCyan)] = settings.cpBrightCyan;
  self.ansiColors[@(AMR_SGRCodeFgBrightWhite)] = settings.cpBrightWhite;
    
  return self;
}

@end
