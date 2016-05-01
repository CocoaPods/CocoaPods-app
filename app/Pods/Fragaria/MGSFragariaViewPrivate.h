//
//  MGSFragariaViewPrivate.h
//  Fragaria
//
//  Created by Jim Derry on 3/25/15.
//
/// @cond PRIVATE

@class MGSSyntaxErrorController;
@class MGSLineNumberView;
@class SMLSyntaxColouring;


#pragma mark - Class Extension


@interface MGSFragariaView()


/** Fragaria's syntax colouring object. */
@property  (nonatomic, assign, readonly) SMLSyntaxColouring *syntaxColouring;

/** Fragaria's gutter view. */
@property (nonatomic, strong, readonly) MGSLineNumberView *gutterView;

/** The controller which manages and displays the syntax errors in Fragaria's
 *  text view and gutter view. */
@property (readonly) MGSSyntaxErrorController *syntaxErrorController;


@end

