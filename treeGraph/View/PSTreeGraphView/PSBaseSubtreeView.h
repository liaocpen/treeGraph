//
//  PSBaseSubtreeView.h
//  treeGraph
//
//  Created by lanhu on 14-2-14.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PSBaseSubtreeView : UIView


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
