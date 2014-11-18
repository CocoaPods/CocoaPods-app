//
//  MGSGlyphGenerator.h
//  Fragaria
//
//  Created by Jonathan on 23/09/2012.
//
//

#import <Cocoa/Cocoa.h>

@interface MGSGlyphGenerator : NSGlyphGenerator <NSGlyphStorage> {
    id <NSGlyphStorage> _destination;
}

@end
