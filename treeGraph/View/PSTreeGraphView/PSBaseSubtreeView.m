//
//  PSBaseSubtreeView.m
//  treeGraph
//
//  Created by lanhu on 14-2-14.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "PSBaseSubtreeView.h"
#import "PSBaseBranchView.h"
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
        if ([ancestor isKindOfClass:[PSBaseTreeGraphView class]]) {
            return (PSBaseTreeGraphView *)ancestor;
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
    
    if ((treeOrientation == PSTreeGraphOrientationStyleHorizontal) || (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped)) {
        nextSubtreeViewOrigin = CGPointMake(rootNodeViewSize.width + parentChildSpacing, 0.0f);
    } else {
        nextSubtreeViewOrigin = CGPointMake(0.0f, rootNodeViewSize.height + parentChildSpacing);
    }
    
    for (index =  count - 1 ; index >= 0; index--) {
        UIView *subview = subviews[index];
        
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            ++subtreeViewCount;
            
            // Unhide the view if needed.
            [subview setHidden:NO];
            
            // Recursively lauout the subtree, and obtain the SubtreeVies's resultant size.
            CGSize subtreeViewSize = [(PSBaseSubtreeView *)subview layoutGraphIfNeeded];
            
            if ((treeOrientation == PSTreeGraphOrientationStyleHorizontal) || (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped)) {
                
                // Since SubtreeView is unflipped, lay out our child subtreeView going upward from our bottom edge,from last to first.
                subview.frame = CGRectMake(nextSubtreeViewOrigin.x,
                                           nextSubtreeViewOrigin.y,
                                           subtreeViewSize.width,
                                           subtreeViewSize.height);
                
                // Advance nextSubtreeViewOrigin for the next SubtreeView.
                nextSubtreeViewOrigin.y += subtreeViewSize.height + siblingSpacing;
                
                // Keep track of the widest SubtreeView width we encounter.
                if (maxWidth < subtreeViewSize.width) {
                    maxWidth = subtreeViewSize.width;
                }
            } else {
                subview.frame = CGRectMake(nextSubtreeViewOrigin.x,
                                           nextSubtreeViewOrigin.y,
                                           subtreeViewSize.width,
                                           subtreeViewSize.height);
                
                nextSubtreeViewOrigin.x += subtreeViewSize.width + siblingSpacing;
                
                if (maxHeight < subtreeViewSize.height) {
                    maxHeight = subtreeViewSize.height;
                }
            }
        }
    }
    
    // Calculate the total height of all our SubtreeViews, including the vertical spacing between them.
    // We have N child SubtreeViews, but only （N - 1）gaps between them, so subtract 1 increment of siblingSpacing that was added by the loop above.
    CGFloat totalHeight = 0.0f;
    CGFloat totalWidth = 0.0f;
    
    if ((treeOrientation == PSTreeGraphOrientationStyleHorizontal) || (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped)) {
        totalHeight = nextSubtreeViewOrigin.y;
        if (subtreeViewCount > 0) {
            totalHeight -= siblingSpacing;
        }
    } else {
        totalWidth = nextSubtreeViewOrigin.x;
        if (subtreeViewCount > 0) {
            totalWidth -= siblingSpacing;
        }
    }
    
    // Size self to contain our nodeView all out child SubtreeViews, and position our nodeView and connectorView.
    if (subtreeViewCount > 0) {
        
        // Determine our width and height
        if ((treeOrientation == PSTreeGraphOrientationStyleHorizontal) || (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped)) {
            selfTargetSize = CGSizeMake(rootNodeViewSize.width + parentChildSpacing + maxWidth, MAX(totalHeight, rootNodeViewSize.height));
        } else {
            selfTargetSize = CGSizeMake(MAX(totalWidth, rootNodeViewSize.width), rootNodeViewSize.height + parentChildSpacing + maxHeight);
        }
        
        /**
         *  Resize to our new width and height.
         */
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                selfTargetSize.width,
                                selfTargetSize.height);

        CGPoint nodeViewOrign = CGPointZero;
        if ((treeOrientation == PSTreeGraphOrientationStyleHorizontal) || (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped)) {
            
            // Position our nodeView vertically centered along the left edge of our new bounds.
            nodeViewOrign = CGPointMake(0.0f, 0.5f * (selfTargetSize.height - rootNodeViewSize.height));
        } else {
            // Position our nodeView horizontally centered along the top edge of our new bounds.
            nodeViewOrign = CGPointMake(0.5f * (selfTargetSize.width - rootNodeViewSize.width), 0.0f);
        }
        
        // Pixel-align its position to keep its rendering crisp.
        CGPoint windowPoint = [self convertPoint:nodeViewOrign toView:nil];
        windowPoint.x = round(windowPoint.x);
        windowPoint.y = round(windowPoint.y);
        nodeViewOrign = [self convertPoint:windowPoint fromView:nil];
        
        self.nodeView.frame = CGRectMake(nodeViewOrign.x,
                                         nodeViewOrign.y,
                                         self.nodeView.frame.size.width,
                                         self.nodeView.frame.size.height);
        
        
        // Position, show our connectorView and button.
        
        if ((treeOrientation == PSTreeGraphOrientationStyleHorizontal) || (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped)) {
            connectorsView_.frame = CGRectMake(
                                               rootNodeViewSize.width,
                                               0.0f, parentChildSpacing, selfTargetSize.height);
        } else {
            connectorsView_.frame = CGRectMake(0.0f,
                                               rootNodeViewSize.height,
                                               selfTargetSize.width, parentChildSpacing);
        }
        
        /**
         *  NOTE: Enable this line if a collapse animation is added
         */
        [connectorsView_ setHidden:NO];
    } else {
        /**
         *  No SubtreeViews; this is a leaf node. 
         *  Size self to exactly wrap nodeView, hide connectorsView, and hide the button.
         */
        
        selfTargetSize = rootNodeViewSize;
        self.frame = CGRectMake(self.frame.origin.x,
                                self.frame.origin.y,
                                selfTargetSize.width,
                                selfTargetSize.height);
        self.nodeView.frame = CGRectMake(0.0f,
                                         0.0f,
                                         self.nodeView.frame.size.width,
                                         self.nodeView.frame.size.height);
        [connectorsView_ setHidden:YES];
    }
    
    // Return our new size.
    return selfTargetSize;
}

- (CGSize)layoutCollapsedGraph
{
    /**
     *  Thsi node is collapsed. Everything will be collapsed behind the leafNode
     */
    CGSize selfTargetSize = [self sizeNodeViewToFitContent];
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            selfTargetSize.width,
                            selfTargetSize.height);
    
    for (UIView *subview in [self subviews]) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            
            [(PSBaseBranchView *)subview layoutIfNeeded];
            subview.frame = CGRectMake(0.0f,
                                       0.0f,
                                       subview.frame.size.width,
                                       subview.frame.size.height);
            [subview setHidden:YES];
        } else if (subview == connectorsView_) {
            PSTreeGraphOrientationStyle treeOrientation = [[self enclosingTreeGraph] treeGraphOritentation];
            if ((treeOrientation == PSTreeGraphOrientationStyleHorizontal) || (treeOrientation == PSTreeGraphOrientationStyleHorizontalFlipped)) {
                connectorsView_.frame = CGRectMake(0.0f,
                                                   0.5f * selfTargetSize.height, 0.0f,
                                                   0.0f);
            } else {
                connectorsView_.frame = CGRectMake(0.5f * selfTargetSize.width,0.0f, 0.0f, 0.f);
            }
            
            [subview setHidden:YES];
        } else if (subview == nodeView_) {
           
            subview.frame = CGRectMake(0.0f, 0.0f, selfTargetSize.width, selfTargetSize.height);
        }
    }
    
    return selfTargetSize;
}

#pragma mark - Drawing

- (void) updateSubtreeBorder
{
    CALayer *layer = [self layer];
    
    PSBaseTreeGraphView *treeGraph = [self enclosingTreeGraph];
    
    if ([treeGraph showSubtreeFrames]) {
        [layer setBorderWidth:subtreeBoederWidth()];
        [layer setBorderColor:[subtreeBorderColor() CGColor]];
    } else {
        [layer setBorderWidth:0.0];
    }
}

#pragma mark - Invalidation

- (void)recursiveSetConnectorsViewsNeedDisplay
{
    // Mark this SubtreeView's  connectorsView as needing display.
    [connectorsView_ setNeedsDisplay];
    
    // Recurse for descendant SubtreeViews
    NSArray *subviews = [self subviews];
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [(PSBaseSubtreeView *)subview recursiveSetConnectorsViewsNeedDisplay];
        }
    }
}

- (void)resursiveSetSubtreeBordersNeedDisplay
{
    [self updateSubtreeBorder];
    
    // Recure for descendant SubtreeViews
    NSArray *subviews = [self subviews];
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [(PSBaseSubtreeView *)subview updateSubtreeBorder];
        }
    }
}

#pragma mark - Selection State

- (BOOL)nodeIsSelected
{
    return [[[self enclosingTreeGraph] selectedModelNodes] containsObject:[self modelNode]];
}

#pragma mark - Node Hit-Testing

- (id<PSTreeGraphModelNode>)modelNodeAtPoint:(CGPoint)p
{
    /**
     *  Check for intersection with our subviews, enumerating them in reverse order to get front-to-back ordering.
     */
    
    NSArray *subviews = [self subviews];
    NSInteger count = [subviews count];
    NSInteger index;
    
    for (index = count - 1; index >= 0; index--) {
        UIView *subview = subviews[index];
        CGPoint subviewPoint = [subview convertPoint:p fromView:self];
        
        if ([subview pointInside:subviewPoint withEvent:nil]) {
            if (subview == [self nodeView]) {
                return [self modelNode];
            } else if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
                [(PSBaseSubtreeView *)subview modelNodeAtPoint:subviewPoint];
            } else {
                // Ignore subview. It's probably a BranchView
            }
        }
    }
    // Don not find a hit.
    return nil;
}

- (id<PSTreeGraphModelNode>)modelNodeClosestoY:(CGFloat)y
{
    // Do a simple linear search of our subviews, ignoring non-SubtreeViews.
    NSArray *subviews = [self subviews];
    PSBaseSubtreeView *subtreeViewWithClosestNodeView = nil;
    CGFloat closestNodeViewDistance = MAXFLOAT;
    
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            UIView *childNodeView = [(PSBaseSubtreeView *)subview nodeView];
            if (childNodeView) {
                CGRect rect = [self convertRect:[childNodeView bounds] fromView:childNodeView];
                CGFloat nodeViewDistance = fabs(y - CGRectGetMidY(rect));
                if (nodeViewDistance < closestNodeViewDistance) {
                    closestNodeViewDistance = nodeViewDistance;
                    subtreeViewWithClosestNodeView = (PSBaseSubtreeView *)subview;
                }
            }
        }
    }
    return [subtreeViewWithClosestNodeView modelNode];
}

-(id<PSTreeGraphModelNode>)modelNodeClosestoX:(CGFloat)x
{
    NSArray *subviews = [self subviews];
    PSBaseSubtreeView *subtreeViewWithClosestNodeView = nil;
    CGFloat closestNodeViewDistance = MAXFLOAT;
    
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            UIView *childNodeView = [(PSBaseSubtreeView *)subview nodeView];
            if (childNodeView) {
                CGRect rect = [self convertRect:[childNodeView bounds] fromView:childNodeView];
                CGFloat nodeViewDistance = fabs(x - CGRectGetMidX(rect));
                if (nodeViewDistance < closestNodeViewDistance) {
                    closestNodeViewDistance = nodeViewDistance;
                    subtreeViewWithClosestNodeView = (PSBaseSubtreeView *)subview;
                }
            }
        }
    }
    
    return [subtreeViewWithClosestNodeView modelNode];
}

#pragma mark - Debugging

-(NSString *)description
{
    return [NSString stringWithFormat:@"SubtreeView<%@>", [modelNode_ description]];
}

- (NSString *) nodeSummary
{
    return [NSString stringWithFormat:@"f=%@ %@", NSStringFromCGRect([nodeView_ frame]), [modelNode_ description]];
}


- (NSString *) treeSummaryWithDepth:(NSInteger)depth
{
    NSEnumerator *subviewsEnumerator = [[self subviews] objectEnumerator];
    UIView *subview;
    NSMutableString *description = [NSMutableString string];
    NSInteger i;
    for (i = 0; i < depth; i++) {
        [description appendString:@"  "];
    }
    [description appendFormat:@"%@\n", [self nodeSummary]];
    while (subview = [subviewsEnumerator nextObject]) {
        if ([subview isKindOfClass:[PSBaseSubtreeView class]]) {
            [description appendString:[(PSBaseSubtreeView *)subview treeSummaryWithDepth:(depth + 1)]];
        }
    }
    return description;
}

@end
