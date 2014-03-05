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
    
    // Create a single bezier path that we'll use to stroke all the lines.
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    // Add a stroke from each child SubtreeView to where we'll put the vertical connection line.
    CGFloat minY = rootPoint.y;
    CGFloat maxY = rootPoint.y;
    CGFloat minX = rootPoint.x;
    CGFloat maxX = rootPoint.x;
    
    UIView *subtreeView = [self superview];
    NSInteger subtreeViewCount = 0;
    
    if ([subtreeView isKindOfClass:[PSBaseSubtreeView class]]) {
        
        for (UIView *subview in [subtreeView subviews]) {
            if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
                ++subtreeViewCount;
                
                CGRect subviewBounds = [subview bounds];
                CGPoint targetPoint = CGPointZero;
                
                if ((treeDirection == PSTreeGraphOrientationStyleHorizontal) || (treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped)) {
                    targetPoint = [self convertPoint:CGPointMake(CGRectGetMinX(subviewBounds), CGRectGetMidY(subviewBounds)) fromView:subview];
                } else {
                    targetPoint = [self convertPoint:CGPointMake(CGRectGetMidX(subviewBounds), CGRectGetMinY(subviewBounds)) fromView:subview];
                }
                
                if ((treeDirection == PSTreeGraphOrientationStyleHorizontal) || (treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped)) {
                    [path moveToPoint:CGPointMake(rootIntersection.x, targetPoint.y)];
                    
                    if (minY > targetPoint.y) {
                        minY = targetPoint.y;
                    }
                    if (maxY < targetPoint.y) {
                        maxY = targetPoint.y;
                    }
                } else {
                    [path moveToPoint:CGPointMake(targetPoint.x, rootIntersection.y)];
                    if (minX > targetPoint.x) {
                        minX = targetPoint.x;
                    }
                    if (maxX < targetPoint.x) {
                        maxX = targetPoint.x;
                    }
                }
                
                [path addLineToPoint:targetPoint];
            }
        }
    }
    
    if (subtreeViewCount) {
        // Add a stroke from rootPoint to where we'll put the vertical connectiong line.
        [path moveToPoint:rootPoint];
        [path addLineToPoint:rootIntersection];
        
        if ((treeDirection == PSTreeGraphOrientationStyleHorizontal)|| (treeDirection == PSTreeGraphOrientationStyleHorizontalFlipped)) {
            // Add a stroke for the vertical connection line.
            [path moveToPoint:CGPointMake(rootIntersection.x, minY)];
            [path addLineToPoint:CGPointMake(rootIntersection.x, maxY)];
        } else {
            // Add a stroke for the vertical connection line.
            [path moveToPoint:CGPointMake(minX, rootIntersection.y)];
            [path addLineToPoint:CGPointMake(maxX, rootIntersection.y)];
        }
    }
    return path;
}

- (void) drawRect:(CGRect)dirtyRect
{
    // Build the set of lines to stroke,according to our enclosingTreeGraph's connectionLineStyle.
    UIBezierPath *path = nil;
    
    switch ([[self enclosingTreeGraph] connectingLineStyle]) {
        case PSTreeGraphConnectingLineStyleDirect:
        default:
            path = [self directConnectionsPath];
            break;
            
        case PSTreeGraphConnectingLineStyleOrthogonal:
            path = [self orthogonalConnectionsPath];
            break;
    }
    
    // Stroke the path with the appropriate color and line width.
    PSBaseTreeGraphView *treeGraph = [self enclosingTreeGraph];
    
    if ([self isOpaque]) {
        // Fill background
        [[treeGraph backgroundColor] set];
        UIRectFill(dirtyRect);
    }
    
    // Draw lines
    [[treeGraph connectingLineColor] set];
    [path setLineWidth:[treeGraph connectingLineWidth]];
    [path stroke];
}







@end
