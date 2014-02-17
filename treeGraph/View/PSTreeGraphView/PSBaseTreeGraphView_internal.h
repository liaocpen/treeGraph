//
//  PSBaseTreeGraphView_internal.h
//  treeGraph
//
//  Created by lanhu on 14-2-14.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSTreeGraphModelNode.h"


@class PSBaseSubtreeView;


@interface PSBaseTreeGraphView ()

#pragma mark - Model Node & SubtreeView Relationship 

/**
 *  @return the SubtreeView that corresponds to the specified modelNode
 */
- (PSBaseSubtreeView *) subtreeViewForModelNode: (id) modelNode;

/**
 *  Associates the specified subtreeView with the given modeNode in the TreeGraph's modelNodeToSubtreeViewMapTable
 */
- (void) setSubtreeView:(PSBaseSubtreeView *)SubtreeView forModelNode:(id)modelNode;

#pragma mark - Model Tree Navigation

/**
 *  @return Yes if modelNode is a descendant of possibleAncestor, No if not.
 */
- (BOOL) modelNode: (id <PSTreeGraphModelNode> ) modelNode
    isDescendantOf: (id <PSTreeGraphModelNode>) possibleAncestor;

/**
 *  @return Yes if modelNode is the TreeGraph's assigned modelRoot,
        or a descendant of modelRoot.
 */
- (BOOL) modelNodeIsInAssignedTree: (id <PSTreeGraphModelNode>) modelNode;

/**
 *  @return the sibling at the given offset relative to the given modelNode.
 */
- (id <PSTreeGraphModelNode>) siblingOfModelNode: (id <PSTreeGraphModelNode>) modelNode
                                 atRelativeIndex: (NSInteger) relativeIndex;

#pragma mark - Node View Nib Caching

/**
 *  Return an UINib instance created from the TreeGraph's nodeViewNibName.
 */
@property (nonatomic, retain) UINib *cachedNodeViewNib;


























































@end
