//
//  SMLSyntaxColouringDelegate.h
//  Fragaria
//
//  Created by Jonathan on 14/04/2013.
//
//

#import <Foundation/Foundation.h>

// syntax colouring information dictionary keys
extern NSString *SMLSyntaxGroup;
extern NSString *SMLSyntaxGroupID;
extern NSString *SMLSyntaxWillColour;
extern NSString *SMLSyntaxAttributes;
extern NSString *SMLSyntaxInfo;

// syntax colouring group names
extern NSString *SMLSyntaxGroupNumber;
extern NSString *SMLSyntaxGroupCommand;
extern NSString *SMLSyntaxGroupInstruction;
extern NSString *SMLSyntaxGroupKeyword;
extern NSString *SMLSyntaxGroupAutoComplete;
extern NSString *SMLSyntaxGroupVariable;
extern NSString *SMLSyntaxGroupFirstString;
extern NSString *SMLSyntaxGroupSecondString;
extern NSString *SMLSyntaxGroupAttribute;
extern NSString *SMLSyntaxGroupSingleLineComment;
extern NSString *SMLSyntaxGroupMultiLineComment;
extern NSString *SMLSyntaxGroupSecondStringPass2;

// syntax colouring group IDs
enum {
    kSMLSyntaxGroupNumber = 0,
    kSMLSyntaxGroupCommand = 1,
    kSMLSyntaxGroupInstruction = 2,
    kSMLSyntaxGroupKeyword = 3,
    kSMLSyntaxGroupAutoComplete = 4,
    kSMLSyntaxGroupVariable = 5,
    kSMLSyntaxGroupSecondString = 6,
    kSMLSyntaxGroupFirstString = 7,
    kSMLSyntaxGroupAttribute = 8,
    kSMLSyntaxGroupSingleLineComment = 9,
    kSMLSyntaxGroupMultiLineComment = 10,
    kSMLSyntaxGroupSecondStringPass2 = 11
};
typedef NSInteger SMLSyntaxGroupInteger;

@protocol SMLSyntaxColouringDelegate <NSObject>

/*
 
 Use these methods to partially customise or overridde the syntax colouring.
 
 Arguments used in the delegate methods
 ======================================
 
 document: Fragaria document spec
 block: block to colour string. the arguments are a colour info dictionary and the range to be coloured
 string: document string. This is supplied as a convenience. The string can also be retrieved from the document.
 range: range of string to colour.
 info: an information dictionary
 
 Info dictionary keys 
 ======================
 
 SMLSyntaxGroup: NSString describing the group being coloured.
 SMLSyntaxGroupID:  NSNumber identyfying the group being coloured.
 SMLSyntaxWillColour: NSNumber containing a BOOL indicating whether the caller will colour the string.
 SMLSyntaxAttributes: NSDictionary of NSAttributed string attributes used to colour the string.
 SMLSyntaxInfo: NSDictionary containing Fragaria syntax definition.
 
 Syntax Info dictionary keys
 ===========================
 
 For key values see SMLSyntaxDefinition.h
 
 Delegate calling
 ================
 
 The delegate will receive messages in the following sequence:
 
 // query delegate if should colour this document
 doColouring = fragariaDocument:shouldColourWithBlock:string:range:info
 if !doColouring quit colouring
 
 // send *ColourGroupWithBlock methods for each group defined by SMLSyntaxGroupInteger
 foreach group
 
    // query delegate if should colour this group
    doColouring = fragariaDocument:shouldColourGroupWithBlock:string:range:info

    if doColouring
 
        colour the group
 
        // inform delegate group was coloured
        fragariaDocument:didColourGroupWithBlock:string:range:info
 
    end if
 end
 
 // inform delegate document was coloured
 fragariaDocument:willDidWithBlock:string:range:info
 
 Colouring the string
 ====================
 
 Each delegate method includes a block that can can be called with a dictionary of attributes and a range to affect colouring.
 
 */
- (BOOL)fragariaDocument:(id)document shouldColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
- (BOOL)fragariaDocument:(id)document shouldColourGroupWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
- (void)fragariaDocument:(id)document didColourGroupWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
- (void)fragariaDocument:(id)document didColourWithBlock:(BOOL (^)(NSDictionary *, NSRange))block string:(NSString *)string range:(NSRange)range info:(NSDictionary *)info;
@end
