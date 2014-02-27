//
//  PSBaseBranchView.m
//  treeGraph
//
//  Created by Liao_Cpen on 14-2-13.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "PSBaseBranchView.h"
#import "PSBaseTreeGraphView.h"
#import "PSBaseSubtreeView.h"


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
        ancestor = [ancestor superview];
    }
    return nil;
}

#pragma mark - Drawing 

-(UIBezierPath *)directConnectionsPath
{
    CGRect bounds = [self bounds];
    CGPoint rootPoint = CGPointZero;
    
    PSTreeGraphOrientationStyle treeDirection = [[self enclosingTreeGraph] treeGraphOritentation];
    if ((treeDirection == PSTreeGraphOrientationStyleHorizontal) || (treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped)) {
        rootPoint = CGPointMake(CGRectGetMinX(bounds),
                                CGRectGetMidY(bounds));
    } else {
        rootPoint = CGPointMake(CGRectGetMidX(bounds),
                                CGRectGetMinY(bounds));
    }
    
    // Creaate a single bezier path that we'll use to stroke all the lines.
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // Add a stroke from rootPoint to each child SubtreeView of out containing SubtreeView.
    UIView *subtreeView = [self superview];
    if ([subtreeView isKindOfClass:[PSBaseSubtreeView class]]) {
        
        for (UIView *subview in [subtreeView subviews]) {
            if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
                CGRect subviewBounds = [subview bounds];
                CGPoint targetPoint = CGPointZero;
                
                if ((treeDirection == PSTreeGraphOrientationStyleHorizontal) || (treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped)) {
                    targetPoint = [self convertPoint:CGPointMake(CGRectGetMinX(subviewBounds), CGRectGetMidY(subviewBounds)) fromView:subview];
                } else {
                    targetPoint = [self convertPoint:CGPointMake(CGRectGetMidX(subviewBounds), CGRectGetMinY(subviewBounds)) fromView:subview];
                }
                
                [path moveToPoint:rootPoint];
                [path addLineToPoint:targetPoint];
            }
        }
    }
    return path;
}

-(UIBezierPath *)orthogonalConnectionsPath
{
    /**
     *  Compute the needed adjustment in x and y to align our lines for crisp, exact pixel coverage.
     */

    CGRect bounds = [self bounds];
    
    PSTreeGraphOrientationStyle treeDirection = [[self enclosingTreeGraph] treeGraphOritentation];
    
    CGPoint rootPoint = CGPointZero;
    if (treeDirection == PSTreeGraphOrientationStyleHorizontal) {
        // Compute the point at right edge of root node, from which its connection line to the vertical line will emerge.
        rootPoint = CGPointMake(CGRectGetMinX(bounds), CGRectGetMidY(bounds));
    } else if (treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped) {
        rootPoint = CGPointMake(CGRectGetMaxX(bounds), CGRectGetMidY(bounds));
    } else if (treeDirection == PSTreeGraphOrientationStyleVerticalFlipped){
        rootPoint = CGPointMake(CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
    } else {
        rootPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMinY(bounds));
    }
    
    // Compute point at which line from root node intersects the vertical connectiong line.
    CGPoint rootIntersection = CGPointMake(CGRectGetMidY(bounds), CGRectGetMidY(bounds));
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
}













@end
