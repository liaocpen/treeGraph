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
