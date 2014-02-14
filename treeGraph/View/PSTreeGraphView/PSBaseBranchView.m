//
//  PSBaseBranchView.m
//  treeGraph
//
//  Created by Liao_Cpen on 14-2-13.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "PSBaseBranchView.h"
#import "PSBaseTreeGraphView.h"

@interface PSBaseBranchView ()

- (UIBezierPath *) directConnectionsPath;
- (UIBezierPath *) orthogonalConnectionsPath;

@end

@implementation PSBaseBranchView

- (PSBaseTreeGraphView *)enclosingTreeGraph
{
    UIView *ancestor = [self superview];
    while (ancestor) {
        if ([ancestor isKindOfClass:[PSBaseTreeGraphView class]]) {
            return (PSBaseTreeGraphView *)ancestor;
        }
    }
    return nil;
}

#pragma mark - Drawing 

-(UIBezierPath *)directConnectionsPath
{
    CGRect bounds = [self bounds];
    CGPoint rootPoint = CGPointZero;
    
    return nil;
}
















@end
