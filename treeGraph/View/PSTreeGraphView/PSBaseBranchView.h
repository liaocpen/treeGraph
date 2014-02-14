//
//  PSBaseBranchView.h
//  treeGraph
//
//  Created by Liao_Cpen on 14-2-13.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSBaseTreeGraphView;

/**
 *  Each SubtreeView has a BranchView subview that draws the connecting lines between its root node and its child subtrees.
 */

@interface PSBaseBranchView : UIView

/**
 *  return Link to the enclosing TreeGraph.
 */
@property (weak, nonatomic, readonly) PSBaseTreeGraphView *enclosingTreeGraph;

@end
