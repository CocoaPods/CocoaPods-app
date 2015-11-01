//
//  MGSDragOperationDelegate.h
//  Fragaria
//
//  Created by Daniele Cattaneo on 08/02/15.
//
//  - Defines the <MGSDragOperationDelegate> that delegates may conform to.
//

#import <AppKit/AppKit.h>


/**
 *  MGSDragOperationDelegate passes the  <NSDraggingDestination> methods to
 *  a delegate so that is it possible to implement the protocol without
 *  having to subclass the view.
 **/
@protocol MGSDragOperationDelegate <NSDraggingDestination>

@optional

/**
 *  Refer to the NSDraggingDestination documentation.
 *  @param sender Indicates the object sending the message.
 **/
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender;

/**
 *  Refer to the NSDraggingDestination documentation.
 **/
- (BOOL)wantsPeriodicDraggingUpdates;

/**
 *  Refer to the NSDraggingDestination documentation.
 *  @param sender Indicates the object sending the message.
 **/
- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender;

/**
 *  Refer to the NSDraggingDestination documentation.
 *  @param sender Indicates the object sending the message.
 **/
- (void)draggingEnded:(id<NSDraggingInfo>)sender;

/**
 *  Refer to the NSDraggingDestination documentation.
 *  @param sender Indicates the object sending the message.
 **/
- (void)draggingExited:(id<NSDraggingInfo>)sender;

/**
 *  Refer to the NSDraggingDestination documentation.
 *  @param sender Indicates the object sending the message.
 **/
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender;

/**
 *  Refer to the NSDraggingDestination documentation.
 *  @param sender Indicates the object sending the message.
 **/
- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender;

/**
 *  Refer to the NSDraggingDestination documentation.
 *  @param sender Indicates the object sending the message.
 **/
- (void)concludeDragOperation:(id <NSDraggingInfo>)sender;

/**
 *  Refer to the NSDraggingDestination documentation.
 *  @param sender Indicates the object sending the message.
 **/
- (void)updateDraggingItemsForDrag:(id<NSDraggingInfo>)sender;

@end
