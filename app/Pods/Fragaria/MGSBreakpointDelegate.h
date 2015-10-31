//
//  MGSBreakpointDelegate.h
//  Fragaria
//
//  Created by Viktor Lidholt on 3/5/13.
//
//

#import <Cocoa/Cocoa.h>


@class MGSFragariaView;


/** The <MGSBreakpointDelegate> protocol specifies methods for delegates
 *  to adopt in order to receive breakpoint-related messages from Fragaria. */

@protocol MGSBreakpointDelegate <NSObject>


@optional


/** Returns a dictionary of NSColors keyed by line numbers. A breakpoint marker
 *  will be shown on the line numbers specified, of the color associated with
 *  that line number.
 *  @discussion This method supersedes both breakpointsForFragaria: and
 *              breakpointColourForLine:ofFragaria:, and is provided as an
 *              higher-performance alternative to these other two methods.
 *              Thus, if you implement colouredBreakpointsForFragaria:, 
 *              breakpointsForFragaria: and breakpointColourForLine:ofFragaria:
 *              will never be called.
 *  @param sender The MGSFragaria instance which sent the message. */
- (NSDictionary *)colouredBreakpointsForFragaria:(MGSFragariaView *)sender;

/** Returns a set of one-based line numbers containing breakpoints.
 *  @param sender The MGSFragaria instance which sent the message.
 *  @return A set of NSNumber indicating the line numbers that have
 *          breakpoints. */
- (NSSet *)breakpointsForFragaria:(MGSFragariaView *)sender;

/** Returns the color for the breakpoint marker to be shown at the specified
 *  line.
 *  @discussion This method is not called for lines which are not included in
 *              the set returned by breakpointsForFragaria:. If this method
 *              returns nil or is unimplemented, a default color is used.
 *  @param line A one-based line number.
 *  @param sender The MGSFragaria instance which sent the message. */
- (NSColor *)breakpointColourForLine:(NSUInteger)line ofFragaria:(MGSFragariaView *)sender;

/** This message is sent to a delegate when Fragaria indicates that a request
 *  to toggle a breakpoint was made.
 *  @param sender The MGSFragaria instance which sent the message.
 *  @param line The one-based line number which the user clicked on. */
- (void)toggleBreakpointForFragaria:(MGSFragariaView *)sender onLine:(NSUInteger)line;


@end
