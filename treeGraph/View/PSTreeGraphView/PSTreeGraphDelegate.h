//
//  PSTreeGraphDelegate.h
//  treeGraph
//
//  Created by lanhu on 14-2-17.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSTreeGraphModelNode;


@protocol PSTreeGraphDelegate <NSObject>

@required

/**
 *  The delegate will configure the nodeView with the modelNode provided.
 */
- (void) configureNodeView: (UIView *)nodeView withModelNode:(id <PSTreeGraphModelNode>)modelNode;

@end
