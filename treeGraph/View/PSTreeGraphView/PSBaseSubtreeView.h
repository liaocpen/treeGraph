//
//  PSBaseSubtreeView.h
//  treeGraph
//
//  Created by lanhu on 14-2-14.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTreeGraphModelNode.h"

@class PSBaseTreeGraphView;


/**
 *  A SubtreeView draws nothing itself (unless showSubtreeFrame is set to Yes for the enclosingTreeGraph), 
 *  but provides a local coordinate frame and grouping mechanism for a graph subtree, and implements subtree layout.
 */

@interface PSBaseSubtreeView : UIView

/**
 *  Initializes a SubtreeView with the associated modelNode. This is subtreeView's designated initializer.
 */
- (id)initWithModelNode:( id <PSTreeGraphModelNode> )newModelNode;

/**
 *  The root of the model subtree that this SubtreeView represents.
 */
@property (nonatomic, strong) id <PSTreeGraphModelNode> modelNode;

/**
 *  The View that represents the modelNode. Is a subView of SubtreeView, and may itself have descendant views.
 */
@property (nonatomic, weak) IBOutlet UIView *nodeView;

/**
 *  Link to the enclosing TreeGraph.
 */
@property (weak, nonatomic, readonly) PSBaseTreeGraphView *enclosingTreeGraph;

/**
 *  Whether the model node repressented by this SubtreeView is a Leaf node .
 */
@property (nonatomic, readonly, getter = isLeaf) BOOL leaf;

#pragma mark - Selection State

/**
 *  Whether the node is part of the TreeGraph's current selection. This can be a useful property to bind user interface state to.
 */
@property (nonatomic, readonly) BOOL nodeIsSelected;

#pragma mark - Layout

/**
 *  Return Yes if this subtree needs relayout.
 */
@property (nonatomic, assign) BOOL needsGraphLayout;

/**
 *  Recursively marks this subtree, and all of its descendants, as needing relayout.
 */
- (void) recursiveSetNeedsGraphLayout;

/**
 *  Recursively perform graph layout, if this subtree is marked as needing it.
 */
- (CGSize) layoutGraphIfNeeded;

/**
 *  Flip the treeGraph end for end(or top for bottom)
 */
- (void) flipTreeGraph;

/**
 *  Resizes this subtree's nodeView to the minimum size required to hold its content, and returns the nodeView's new size.
 */
- (CGSize)sizeNodeViewToFitContent;

/**
 *  Whether this subtree is currently shown as expanded. If NO, the node's children have been collapsed into it.
 */
@property (nonatomic, assign, getter = isExpanded) BOOL expanded;

/**
 *  Toggles expansion of this subtree. This can be wired up as the action of a button or other user interface control.
 *
 */
- (IBAction)toggleExpansion:(id)sender;


#pragma mark - Invalidation

/**
 *  Marks all BranchView instances in this subtree as needing display.
 */
- (void) recursiveSetConnectorsViewsNeedDisplay;

/**
 *  Marks all SubtreeView debug borders as needing display.
 */
- (void) resursiveSetSubtreeBordersNeedDisplay;

#pragma mark - Node Hit -Testing

/**
 *  Returns the Visible model node whose nodeView contains the given point 'p', where 'p' is specified in the SubtreeView's interior
    coordinate space. Returns nil if there is no node under the specified point. When a subtree is collapsed, only its root nodeView is eligible for hit-testing.
 */
- (id <PSTreeGraphModelNode>) modelNodeAtPoint: (CGPoint)p;

/**
 *  Returns the Visible model node that is closest to the specified Y coordinate, where 'Y' is specified in the SubtreeView's interior coordinate space.
 */
- (id <PSTreeGraphModelNode>) modelNodeClosestoY: (CGFloat)y;


/**
 *  Returns the Visible model node that is closest to the specified X coordinate, where 'X' is specified in the SubtreeView's interior coordinate space.
 */
- (id <PSTreeGraphModelNode>) modelNodeClosestoX: (CGFloat)x;


#pragma mark -Debugging

/**
 *  Returns an indented muti-line NSString summary of the displayer tree.Provided as a debugging aid.
 */
- (NSString *) treeSummaryWithDepth:(NSInteger)depth;
@end
