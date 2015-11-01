//
//  SMLTextView+JSDExtension.m
//  Fragaria
//
//  File created by Jim Derry on 2015/02/07.
//
//  - Extends SMLTextView to use its delegate to pass off its <NSDraggingDestination> methods to the delegate.
//  - Implements the required <NSDraggingDestination> protocol classes, passing them on to the delegate.
//  - Defines the <MGSDragOperationDelegate> that delegates may conform to.
//

#import <objc/runtime.h>
#import "SMLTextView+MGSDragging.h"
#import "MGSDragOperationDelegate.h"


@implementation SMLTextView (MGSDragging)


#pragma mark - <NSDraggingDestination> adherence for SMLTextView


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	draggingEntered:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if ([self.delegate respondsToSelector:@selector(draggingEntered:)])
    {
        return [(id<MGSDragOperationDelegate>)self.delegate draggingEntered:sender];
    }
    else
    {
        return [super draggingEntered:sender];
    }
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	wantsPeriodicDraggingUpdates
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)wantsPeriodicDraggingUpdates
{
    if ([self.delegate respondsToSelector:@selector(wantsPeriodicDraggingUpdates)])
    {
        return [(id<MGSDragOperationDelegate>)self.delegate wantsPeriodicDraggingUpdates];
    }
    else
    {
        return NO; // We're a category and there's no inherited implementation.
    }
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	draggingUpdated:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    if ([self.delegate respondsToSelector:@selector(draggingUpdated:)])
    {
        return [(id<MGSDragOperationDelegate>)self.delegate draggingUpdated:sender];
    }
    else
    {
        return [super draggingUpdated:sender];
    }
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	draggingEnded:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    if ([self.delegate respondsToSelector:@selector(draggingEnded:)])
    {
        [(id<MGSDragOperationDelegate>)self.delegate draggingEnded:sender];
    }
    else
    {
        // We're a category and there's no inherited implementation.
    }
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	draggingExited:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    if ([self.delegate respondsToSelector:@selector(draggingExited:)])
    {
        [(id<MGSDragOperationDelegate>)self.delegate draggingExited:sender];
    }
    else
    {
        [super draggingExited:sender];
    }
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	prepareForDragOperation:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    if ([self.delegate respondsToSelector:@selector(prepareForDragOperation:)])
    {
        return [(id<MGSDragOperationDelegate>)self.delegate prepareForDragOperation:sender];
    }
    else
    {
        return [super prepareForDragOperation:sender];
    }
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	performDragOperation:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    if ([self.delegate respondsToSelector:@selector(performDragOperation:)])
    {
        return [(id<MGSDragOperationDelegate>)self.delegate performDragOperation:sender];
    }
    else
    {
        return [super performDragOperation:sender];
    }
}

/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	concludeDragOperation:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    if ([self.delegate respondsToSelector:@selector(concludeDragOperation:)])
    {
        [(id<MGSDragOperationDelegate>)self.delegate concludeDragOperation:sender];
    }
    else
    {
        [super concludeDragOperation:sender];
    }
}


/*–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*
	updateDraggingItemsForDrag:
 *–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––*/
- (void)updateDraggingItemsForDrag:(id<NSDraggingInfo>)sender
{
    if ([self.delegate respondsToSelector:@selector(updateDraggingItemsForDrag:)])
    {
        [(id<MGSDragOperationDelegate>)self.delegate updateDraggingItemsForDrag:sender];
    }
    else
    {
        [super updateDraggingItemsForDrag:sender];
    }
}


@end
