//
//  NSScanner+Fragaria.h
//  Fragaria
//
//  Created by Jonathan on 12/08/2010.
//  Copyright 2010 mugginsoft.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>


/**
 *  This category adds features to NSScanner.
 **/
@interface NSScanner (Fragaria)

/**
 *  mgs_setScanLocation ensures the idx is not beyond the length of the document.
 *  If it is the location is set to the end of the text, and a message is written
 *  to the console.
 *  @param idx The character position to double-check.
 **/
- (void)mgs_setScanLocation:(NSUInteger)idx;

@end
