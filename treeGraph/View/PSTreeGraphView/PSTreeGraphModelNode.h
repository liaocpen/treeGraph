//
//  PSTreeGraphModelNode.h
//  treeGraph
//
//  Created by lanhu on 14-2-13.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSTreeGraphModelNode <NSObject>

@required

/**
 *  @return The model node's parent node, or nil if it doesn't have a parent node
 */
- (id <PSTreeGraphModelNode>)parentModeNode;


/**
 *  @return The model node's child nodes, or empty array if it doesn't have child nodes.
 */
- (NSArray *)childModeNodes;

@end
