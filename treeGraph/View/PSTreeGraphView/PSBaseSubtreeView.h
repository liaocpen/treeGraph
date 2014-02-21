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

@interface PSBaseSubtreeView : UIView

/**
 *  Initializes a SubtreeView with the associated modelNode. This is subtreeView's designated initializer.
 */
- (id)initWithModelNode:( id <PSTreeGraphModelNode> )newModelNode;

/**
 *  The View that represents the modelNode. Is a subView of SubtreeView, and may itself have descendant views.
 */
@property (nonatomic, weak) IBOutlet UIView *nodeView;

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
@end
