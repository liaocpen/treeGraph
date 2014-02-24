//
//  PSBaseSubtreeView.m
//  treeGraph
//
//  Created by lanhu on 14-2-14.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "PSBaseSubtreeView.h"
#import "PSBaseBranchView.m"
#import "PSBaseTreeGraphView.h"

#import <QuartzCore/QuartzCore.h>

static UIColor *subtreeBorderColor()
{
    return [UIColor colorWithRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
}

static CGFloat subtreeBoederWidth()
{
    return 2.0f;
}

#pragma mark - Internal Interface

@interface PSBaseSubtreeView ()
{
@private
    /**
     *  Model. the model node that nodeView represents.
     */
    id <PSTreeGraphModelNode> modelNode_;
    
    /**
     *  Views
     */
    UIView *__weak nodeView_;
    
    // The View that shows the connections from nodeView to its child nodes.
    PSBaseBranchView *connectorsView_;
    
    /**
     *  State
     */
    BOOL expanded_;
    BOOL needsGraphLayout_;
}

- (CGSize) layoutExpandedGraph;
- (CGSize) layoutCollapsedGraph;
@end


@implementation PSBaseSubtreeView

#pragma mark - Attributes

@synthesize modelNode = modelNode_;
@synthesize nodeView = nodeView_;

@synthesize expanded = expanded_;

- (void)setExpanded:(BOOL)flag
{
    if (expanded_ != flag) {
        expanded_ = flag;
        
        // Notify the TreeGraph we need Layout.
        [[self enclosingTreeGraph] setNeedsGraphLayout];
        
        for (UIView *subview in [self subviews]) {
            if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
                [(PSBaseSubtreeView *)subview setExpanded:expanded_];
            }
        }
    }
}

- (IBAction)toggleExpansion:(id)sender
{
    [UIView beginAnimations:@"TreeNodeExpansion" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [self setExpanded:[self isExpanded]];
    
    [[self enclosingTreeGraph] layoutGraphIfNeeded];
    
    if ([self modelNode] != nil) {
        NSSet *visibleSet = [NSSet setWithObject:[self modelNode]];
        [[self enclosingTreeGraph] scrollModelNodesToVisible:visibleSet animated:NO];
    }
    
    [UIView commitAnimations];
}

- (BOOL)isLeaf
{
    return [[[self modelNode] childModeNodes] count] == 0;
}

#pragma mark - Instance Initialization

- (id)initWithModelNode:(id<PSTreeGraphModelNode>)newModelNode
{
    NSParameterAssert(newModelNode);
    self = [super initWithFrame:CGRectMake(10.0, 10.0, 100.0, 25.0)];
    if (self) {
        
        expanded_ = YES;
        needsGraphLayout_ = YES;
        
        /**
         *  autoresizeSubviews defaults to YES. Don't want autoresizing, which would interfere with the explicit layout I do.
         */
        [self setAutoresizesSubviews:NO];
        
        self.modelNode = newModelNode;
        connectorsView_ = [[PSBaseBranchView alloc] initWithFrame:CGRectZero];
        if (connectorsView_) {
            [connectorsView_ setAutoresizesSubviews:YES];
            [connectorsView_ setContentMode:UIViewContentModeRedraw];
            [connectorsView_ setOpaque:YES];
            
            [self addSubview:connectorsView_];
        }
    }
    return self;
}

- (PSBaseTreeGraphView *)enclosingTreeGraph
{
    UIView *ancestor = [self superview];
    while (ancestor) {
        if ([ancestor isKindOfClass:[PSBaseBranchView class]]) {
            return (PSBaseBranchView *)ancestor;
        }
        ancestor = [ancestor superview];
    }
    return nil;
}


#pragma makr - Layout

@synthesize needsGraphLayout = needsGraphLayout_;

- (void)recursiveSetNeedsGraphLayout
{
    [self setNeedsGraphLayout:YES];
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [(PSBaseSubtreeView *)subview recursiveSetNeedsGraphLayout];
        }
    }
}

- (CGSize)sizeNodeViewToFitContent
{
    /**
     *  Node size is hardwired for now, but the layout algorithm could accommodate variable-sized nodes if we implement size-to-fit for nodes.
     */
    return [self.nodeView frame].size;
}

-(void)flipTreeGraph
{
    /**
     *  Recure for descendant SuntreeViews.
     */
    CGFloat myWidth = self.frame.size.width;
    CGFloat myHeight = self.frame.size.height;
    PSBaseTreeGraphView *treeGraph = [self enclosingTreeGraph];
    
    PSTreeGraphOrientationStyle treeOrientation = [treeGraph treeGraphOritentation];
    
    for (UIView *subview in [self subviews]) {
        CGPoint subviewCenter = subview.center;
        CGPoint newCenter;
        CGFloat offset;
        
        if (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped) {
            offset = subviewCenter.x;
            newCenter = CGPointMake(myWidth - offset, subviewCenter.y);
        } else {
            offset = subviewCenter.y;
            newCenter = CGPointMake(subviewCenter.x, myHeight - offset);
        }
        
        subview.center = newCenter;
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [(PSBaseSubtreeView *)subview flipTreeGraph];
        }
    }
    
}

- (CGSize)layoutGraphIfNeeded
{
    // Return size if layout not need.
    if (!self.needsGraphLayout) {
        return [self frame].size;
    }
    
    // Do the layout
    CGSize selfTargetSize;
    if ([self isExpanded]) {
        selfTargetSize = [self layoutExpandedGraph];
    } else {
        selfTargetSize = [self layoutCollapsedGraph];
    }
    
    // Marks as having completed layout
    self.needsGraphLayout = NO;
    
    
    return selfTargetSize;
    
}

-(CGSize)layoutExpandedGraph
{
    CGSize selfTargetSize;
    
    PSBaseTreeGraphView *treeGraph = [self enclosingTreeGraph];
    
    CGFloat parentChildSpacing = [treeGraph parentChildSpacing];
    CGFloat siblingSpacing = [treeGraph siblingSpacing];
    PSTreeGraphOrientationStyle treeOrientation = [treeGraph treeGraphOritentation];
    
    /**
     *  Size this SubtreeView's nodeView to fit its content.
     */
    CGSize rootNodeViewSize = [self sizeNodeViewToFitContent];
    
    /**
     *  Recurse to lay out each of our child SubtreeViews.
     */
    NSArray *subviews = [self subviews];
    NSInteger count = [subviews count];
    NSInteger index;
    NSUInteger subtreeViewCount = 0;
    CGFloat maxWidth = 0.0f;
    CGFloat maxHeight = 0.0f;
    CGPoint nextSubtreeViewOrigin = CGPointZero;
    
    
}


























@end
