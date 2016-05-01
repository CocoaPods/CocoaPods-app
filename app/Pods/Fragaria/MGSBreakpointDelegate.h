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
 *  @return An NSSet of NSNumbers, or an NSIndexSet, indicating the line
 *          numbers that have breakpoints. */
- (id)breakpointsForFragaria:(MGSFragariaView *)sender;

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

/** Tells the delegate that some lines were added or deleted from the text,
 *  to allow fixing any breakpoints that lie on these lines.
 *  @discussion Your implementation of this method should call
 *              -reloadBreakpointData on sender if any line number had to be
 *              fixed (it is not automatic).
 *  @param newRange The affected range of one-based line numbers.
 *  @param delta How many lines were added (if positive) or deleted (if
 *               negative) during the edit.
 *  @param sender The MGSFragaria instance which sent the message. */
- (void)fixBreakpointsOfAddedLines:(NSInteger)delta inLineRange:(NSRange)newRange ofFragaria:(MGSFragariaView *)sender;

/** Allows the delegate to return a contextual menu for the specified
 *  breakpoint line.
 *  @discussion This method is called even if there is no breakpoint set on
 *              the specified line.
 *  @param line The line associated to the contextual menu.
 *  @param sender The MGSFragaria instance which sent the message.
 *  @return A NSMenu, or nil if you don't want to show a contextual menu. */
- (NSMenu *)menuForBreakpointInLine:(NSUInteger)line ofFragaria:(MGSFragariaView *)sender;


@end
