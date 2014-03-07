//
//  PSBaseTreeGraphView.m
//  treeGraph
//
//  Created by Liao_Cpen on 14-2-13.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "PSBaseTreeGraphView.h"
#import "PSBaseTreeGraphView_internal.h"
#import "PSBaseSubtreeView.h"
#import "PSBaseLeafView.h"

#import "PSTreeGraphDelegate.h"
#import "PSTreeGraphModelNode.h"
#import "ObjCClassWrapper.h"

#import <QuartzCore/QuartzCore.h>


#pragma mark - Internal Interface

@interface PSBaseTreeGraphView ()
{
@private
    //model
    id <PSTreeGraphModelNode> modelRoot_;
    
    __weak id <PSTreeGraphDelegate> delegate_;

    //Model Object - SubtreeView Mapping
    NSMutableDictionary *modelNodeToSubtreeViewMapTable_;

    //Selection State
    NSSet *selectedModelNodes_;
    
    //Layout State
    CGSize minimumFrameSize_;
    
    //Animation Support
    BOOL animatesLayout_;
    BOOL layoutAnimationSuppressed_;
    
    //Layout Metrics
    CGFloat contentMargin_;
    CGFloat parentChildSpacing_;
    CGFloat siblingSpacing_;
    
    //Layout Behavior
    BOOL resizesToFillEnclosingScrollView_;
    PSTreeGraphOrientationStyle treeGraphOrientation_;
    BOOL treeGraphFlipped_;
    
    // Styling
    UIColor *connectingLineColor_;
    CGFloat connectingLineWidth_;
    PSTreeGraphConnectingLineStyle connectingLineStyle_;
    
    BOOL showSubtreeFrames_;
    
    //Node View Nib Specification
    NSString *nodeViewNibName_;

    UINib *cachedNodeViewNib_;
    
    //custom input view support
    UIView *showDetailView_;
}

- (void) configureDefaults;
- (PSBaseSubtreeView *) newGraphForModelNode:(id <PSTreeGraphModelNode>)modelNode;
- (void) buildGraph;
- (void) updateFrameSizeForContentAndClipView;
- (void) updateRootSubtreeViewPositionForSize:(CGSize)rootSubtreeViewSize;

@end

@implementation PSBaseTreeGraphView

@synthesize delegate = delegate_;
@synthesize layoutAnimationSuppressed = layoutAnimationSuppressed_;
@synthesize minimumFrameSize = minimumFrameSize_;

#pragma mark - Styling

@synthesize animatesLayout = animatesLayout_;
@synthesize connectingLineColor = connectingLineColor_;

- (void) setConnectingLineColor:(UIColor *)newConnectingLineColor
{
    if (connectingLineColor_ != newConnectingLineColor) {
        connectingLineColor_ = newConnectingLineColor;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize contentMarigin = contentMargin_;

- (void) setContentMarigin:(CGFloat)newContentMarigin
{
    if (contentMargin_ != newContentMarigin) {
        contentMargin_ = newContentMarigin;
        [self setNeedsGraphLayout];
    }
}

@synthesize parentChildSpacing = parentChildSpacing_;

- (void) setParentChildSpacing:(CGFloat)newParentChildSpacing
{
    if (parentChildSpacing_ != newParentChildSpacing) {
        parentChildSpacing_ = newParentChildSpacing;
        [self setNeedsGraphLayout];
    }
}

@synthesize siblingSpacing = siblingSpacing_;

- (void) setSiblingSpacing:(CGFloat)newSiblingSpacing
{
    if (siblingSpacing_ != newSiblingSpacing) {
        siblingSpacing_ = newSiblingSpacing;
        [self setNeedsGraphLayout];
    }
}

@synthesize treeGraphOritentation = treeGraphOrientation_;

- (void)setTreeGraphOritentation:(PSTreeGraphOrientationStyle)newTreeGraphOritentation
{
    if (treeGraphOrientation_ != newTreeGraphOritentation) {
        treeGraphOrientation_ = newTreeGraphOritentation;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize treeGraphFlipped = treeGraphFlipped_;

- (void)setTreeGraphFlipped:(BOOL)newTreeGraphFlipped
{
    if (treeGraphFlipped_ != newTreeGraphFlipped) {
        treeGraphFlipped_ = newTreeGraphFlipped;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize connectingLineStyle = connectingLineStyle_;

- (void)setConnectingLineStyle:(PSTreeGraphConnectingLineStyle)newConnectingLineStyle
{
    if (connectingLineStyle_ != newConnectingLineStyle) {
        connectingLineStyle_ = newConnectingLineStyle;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize connectingLineWidth = connectingLineWidth_;

-(void)setConnectingLineWidth:(CGFloat)newConnectingLineWidth
{
    if (connectingLineWidth_ != newConnectingLineWidth) {
        connectingLineWidth_ = newConnectingLineWidth;
        [[self rootSubtreeView] recursiveSetConnectorsViewsNeedDisplay];
    }
}

@synthesize resizesToFillEnclosingScrollView = resizesToFillEnclosingScrollView_;

-(void)setResizesToFillEnclosingScrollView:(BOOL)flag
{
    if (resizesToFillEnclosingScrollView_ != flag) {
        resizesToFillEnclosingScrollView_ = flag;
        [self updateFrameSizeForContentAndClipView];
        [self updateRootSubtreeViewPositionForSize:[[self rootSubtreeView] frame].size];
    }
}

@synthesize showSubtreeFrames = showSubtreeFrames_;

- (void)setShowSubtreeFrames:(BOOL)new
{
    if (showSubtreeFrames_ != new) {
        showSubtreeFrames_ = new;
        [[self rootSubtreeView] resursiveSetSubtreeBordersNeedDisplay];
    }
}

#pragma mark - Initialization 

- (void)configureDefaults
{
    [self setBackgroundColor: [UIColor colorWithRed:0.55 green:0.76 blue:0.93 alpha:1.0]];
    
    connectingLineColor_ = [UIColor blackColor];
    contentMargin_ = 20.0;
    parentChildSpacing_ = 50.0;
    siblingSpacing_ = 10.0;
    animatesLayout_ = YES;
    resizesToFillEnclosingScrollView_ = YES;
    treeGraphFlipped_ = NO;
    treeGraphOrientation_  = PSTreeGraphOrientationStyleHorizontal;
    connectingLineStyle_ = PSTreeGraphConnectingLineStyleOrthogonal;
    connectingLineWidth_ = 1.0;
    
    //Internal
    layoutAnimationSuppressed_ = NO;
    showSubtreeFrames_ = NO;
    minimumFrameSize_ = CGSizeMake(2.0 * contentMargin_, 2.0 * contentMargin_);
    selectedModelNodes_ = [[NSMutableSet alloc] init];
    modelNodeToSubtreeViewMapTable_ = [NSMutableDictionary dictionaryWithCapacity:10];
    
    if (showDetailView_ == nil) {
        showDetailView_ = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width + 250, 0, 500, self.frame.size.height)];
        [showDetailView_ setBackgroundColor:[UIColor whiteColor]];
    }
    
    
    
}

#pragma mark - Resource Management

-(void)dealloc
{
    self.delegate = nil;
}

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureDefaults];
    }
    return self;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:animatesLayout_ forKey:@"animatesLayout"];
    [aCoder encodeFloat:contentMargin_ forKey:@"contentMargin"];
    [aCoder encodeFloat:parentChildSpacing_ forKey:@"parentChildSpacing"];
    [aCoder encodeFloat:siblingSpacing_ forKey:@"siblingSpacing"];
    [aCoder encodeBool:resizesToFillEnclosingScrollView_ forKey:@"resizesToFillEnclosingScrollView"];
    [aCoder encodeObject:connectingLineColor_ forKey:@"connectingLineColor"];
    [aCoder encodeFloat:connectingLineWidth_ forKey:@"connectingLineWidth"];
    [aCoder encodeInt:treeGraphOrientation_ forKey:@"treeGraphOrientation"];
    [aCoder encodeInt:connectingLineStyle_ forKey:@"connectingLineStyle"];
}

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self configureDefaults];
        if ([decoder containsValueForKey:@"animatesLayout"]) {
            animatesLayout_ = [decoder decodeBoolForKey:@"animatesLayout"];
        }
        if ([decoder containsValueForKey:@"contentMargin"])
            contentMargin_ = [decoder decodeFloatForKey:@"contentMargin"];
        if ([decoder containsValueForKey:@"parentChildSpacing"])
            parentChildSpacing_ = [decoder decodeFloatForKey:@"parentChildSpacing"];
        if ([decoder containsValueForKey:@"siblingSpacing"])
            siblingSpacing_ = [decoder decodeFloatForKey:@"siblingSpacing"];
        if ([decoder containsValueForKey:@"resizesToFillEnclosingScrollView"])
            resizesToFillEnclosingScrollView_ = [decoder decodeBoolForKey:@"resizesToFillEnclosingScrollView"];
        if ([decoder containsValueForKey:@"connectingLineColor"])
            connectingLineColor_ = [decoder decodeObjectForKey:@"connectingLineColor"];
        if ([decoder containsValueForKey:@"connectingLineWidth"])
            connectingLineWidth_ = [decoder decodeFloatForKey:@"connectingLineWidth"];
        
        if ([decoder containsValueForKey:@"treeGraphOrientation"])
            treeGraphOrientation_ = [decoder decodeIntForKey:@"treeGraphOrientation"];
        if ([decoder containsValueForKey:@"connectingLineStyle"])
            connectingLineStyle_ = [decoder decodeIntForKey:@"connectingLineStyle"];
    }
    return self;
}

#pragma mark - Root SubtreeView Access

- (PSBaseSubtreeView *) rootSubtreeView
{
    return [self subtreeViewForModelNode:[self modelRoot]];
}

#pragma mark - Node View Nib Cache

- (UINib *)cachedNodeViewNib
{
    return cachedNodeViewNib_;
}

- (void)setCachedNodeViewNib:(UINib *)newNib
{
    if (cachedNodeViewNib_ != newNib) {
        cachedNodeViewNib_ = newNib;
    }
}

#pragma mark - Node View Nib Specification

@synthesize nodeViewNibName = nodeViewNibName_;

- (void)setNodeViewNibName:(NSString *)newName
{
    if (nodeViewNibName_ != newName) {
        [self setCachedNodeViewNib:nil];
        nodeViewNibName_ = [newName copy];
    }
}

#pragma mark - Selection State

/**
 *  The unordered set of model nodes that are currently selected in the TreeGraph.
 */

@synthesize selectedModelNodes = selectedModelNodes_;

-(void)setSelectedModelNodes:(NSSet *)newSelectedModelNodes
{
    NSParameterAssert(newSelectedModelNodes != nil);
    
    /**
     *  Verify that each of the nodes in the new selection is in the TreeGraph's assign model tree.
     */
    for (id modelNode in newSelectedModelNodes) {
        NSAssert([self modelNodeIsInAssignedTree:modelNode], @"modelNode is not in the tree");
    }
    
    if (selectedModelNodes_ != newSelectedModelNodes) {
        NSMutableSet *combineSet = [selectedModelNodes_ mutableCopy];
        [combineSet unionSet:newSelectedModelNodes];
        
        
        NSMutableSet *intersectionSet = [selectedModelNodes_ mutableCopy];
        //交集
        [intersectionSet intersectSet:newSelectedModelNodes];

        
        NSMutableSet *differenceSet = [combineSet mutableCopy];
        //交集的补集
        [differenceSet minusSet:intersectionSet];
        
        
        selectedModelNodes_ = [newSelectedModelNodes mutableCopy];
        
        for (id <PSTreeGraphModelNode> modelNode in differenceSet) {
            PSBaseSubtreeView *subtreeView = [self subtreeViewForModelNode:modelNode];
            UIView *nodeView = [subtreeView nodeView];
            if (nodeView && [nodeView isKindOfClass:[PSBaseLeafView class]]) {
                /**
                 *  Highlighting the currently hardwired to our use of ContainerView
                 */
                [(PSBaseLeafView *)nodeView setShowingSelected:([newSelectedModelNodes containsObject:modelNode] ? YES : NO)];
            }
        }
    }
}

- (id<PSTreeGraphModelNode>)singleSelectedModelNode
{
    NSSet *selection = [self selectedModelNodes];
    return ([selection count] == 1) ? [selection anyObject] : nil;
}

- (CGRect)selectionBounds
{
    return [self boundsOfModelNodes:[self selectedModelNodes]];
}

#pragma mark - Graph Building

- (PSBaseSubtreeView *)newGraphForModelNode:(id<PSTreeGraphModelNode>)modelNode
{
    NSParameterAssert(modelNode);
    
    PSBaseSubtreeView *subtreeView = [[PSBaseSubtreeView alloc] initWithModelNode:modelNode];
    if (subtreeView) {
        
        // Get nib from which to load nodeView.
        UINib *nodeViewNib = [self cachedNodeViewNib];
        
        if (nodeViewNib == nil) {
            NSString *nibName = [self nodeViewNibName];
            NSAssert(nibName != nil, @"You must set a non-nil nodeViewNibName for TreeGraph to be able to build its view tree");
            if (nibName != nil) {
                nodeViewNib = [UINib nibWithNibName:[self nodeViewNibName] bundle:[NSBundle mainBundle]];
                [self setCachedNodeViewNib:nodeViewNib];
            }
        }
        
        NSArray *nibViews = nil;
        if (nodeViewNib != nil) {

            // Instantiate the nib to create out nodeView and associate it with the subtreeView (the nib's owner).
            nibViews = [nodeViewNib instantiateWithOwner:subtreeView options:nil];
        }
        
        if (nibViews) {
            
            // Ask our delegate to configure the interface for the modelNode displayed in nodeView.
            if ( [[self delegate] conformsToProtocol:@protocol(PSTreeGraphDelegate)]) {
                [[self delegate] configureNodeView:[subtreeView nodeView] withModelNode:modelNode];
            }
            
            //Add the nodeView as a subView of the subtreeView
            [subtreeView addSubview:[subtreeView nodeView]];
            
            //Register the subtreeView in map table, so we can look it up by ites modelNode.
            [self setSubtreeView:subtreeView forModelNode:modelNode];
            
            /**
             *  Recurse to create a SubtreeView for each descendant of modelNode.
             */
            NSArray *childModelNodes = [modelNode childModeNodes];
            
            NSAssert(childModelNodes != nil, @"childModelNodes should return an empty array, not nil");
            
            if (childModelNodes != nil) {
                for (id <PSTreeGraphModelNode> childModelNode in childModelNodes) {
                    PSBaseSubtreeView *childSubtreeView = [self newGraphForModelNode:childModelNode];
                    if (childSubtreeView != nil) {
                        
                        /**
                         *  Add the child subtreeView behind the parent subtreeView's nodeView
                         */
                        [subtreeView insertSubview:childSubtreeView belowSubview:[subtreeView nodeView]];
                    }
                }
            }
        } else {
            subtreeView = nil;
        }
    }
    return subtreeView;
}

- (void)buildGraph
{
    @autoreleasepool {
        
        /**
         *  Traverse the model tree, building a SubtreeView for each model node.
         */
        
        id <PSTreeGraphModelNode> root = [self modelRoot];
        if (root) {
            PSBaseSubtreeView *rootSubtreeView = [self newGraphForModelNode:root];
            if (rootSubtreeView) {
                [self addSubview:rootSubtreeView];
            }
        }
    }
     [self addSubview:showDetailView_];
}

#pragma mark -Layout

- (void)updateFrameSizeForContentAndClipView
{
    CGSize newframeSize;
    CGSize newMinimumFrameSize = [self minimumFrameSize];
    
    // Additional
    UIScrollView *enclosingScrollView = (UIScrollView *)[self superview];
    
    if ([self resizesToFillEnclosingScrollView] && enclosingScrollView) {
        
        // This TreeGraph is a child of a UIScrollView: Size it to always fill the content area(at minimum).
        
        CGRect contentViewBounds = [enclosingScrollView bounds];
        newframeSize.width = MAX(newMinimumFrameSize.width, contentViewBounds.size.width);
        newframeSize.height = MAX(newMinimumFrameSize.height, contentViewBounds.size.height);
        
        [enclosingScrollView setContentSize:newframeSize];
    } else {
        newframeSize = newMinimumFrameSize;
    }
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            newframeSize.width,
                            newframeSize.height);
}

- (void)updateRootSubtreeViewPositionForSize:(CGSize)rootSubtreeViewSize
{
    // Position the rootSubtreeView within the TreeGraph.
    PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
    
    CGPoint newOrigin;
    if ([self resizesToFillEnclosingScrollView]) {
        CGRect bounds = [self bounds];
        
        if (([self treeGraphOritentation] == PSTreeGraphOrientationStyleHorizontal) ||
            ([self treeGraphOritentation] == PSTreeGraphOrientationStyleHorizontalFlipped)) {
           
            newOrigin = CGPointMake([self contentMarigin],
                                    0.5 * (bounds.size.height - rootSubtreeViewSize.height));
            
        } else {
            newOrigin = CGPointMake(0.5 * (bounds.size.width - rootSubtreeViewSize.width), [self contentMarigin]);
        }
    } else {
        newOrigin = CGPointMake([self contentMarigin], [self contentMarigin]);
    }
    
    rootSubtreeView.frame = CGRectMake(newOrigin.x, newOrigin.y, rootSubtreeViewSize.width, rootSubtreeViewSize.height);
}

- (void)parentClipViewDidResize:(id)object
{
    UIScrollView *enclosingScrollView = (UIScrollView *)[self superview];
    if (enclosingScrollView && [enclosingScrollView isKindOfClass:[UIScrollView class]]) {
        [self updateFrameSizeForContentAndClipView];
        [self updateRootSubtreeViewPositionForSize:[self rootSubtreeView].frame.size];
        [self scrollSelectedModelNodesToVisbleAnimated:NO];
    }
}

- (void)layoutSubviews
{
    [self layoutGraphIfNeeded];
}

- (CGSize)layoutGraphIfNeeded
{
    PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
    if ([self needsGraphLayout] && [self modelRoot]) {
        
        // Do recursive graph layout, string at our rootSubtreeView.
        CGSize rootSubtreeViewSize = [rootSubtreeView layoutGraphIfNeeded];
        
        // Compute self's new minimumFrameSize. Make sure it's pixel-integral
        CGFloat margin = [self contentMarigin];
        CGSize minimumBoundsSize = CGSizeMake(rootSubtreeViewSize.width + 2.0 * margin, rootSubtreeViewSize.height + 2.0 * margin);
        [self setMinimumFrameSize:minimumBoundsSize];
        
        
        // Set the TreeGraph's frame size
        [self updateFrameSizeForContentAndClipView];
        
        // Position the treeGraph's root SubtreeView.
        [self updateRootSubtreeViewPositionForSize:rootSubtreeViewSize];
        
        if (([self treeGraphOritentation] == PSTreeGraphOrientationStyleHorizontalFlipped) || ([self treeGraphOritentation] == PSTreeGraphOrientationStyleVerticalFlipped)) {
            [rootSubtreeView flipTreeGraph];
        }
        return rootSubtreeViewSize;
        
    } else {
        return rootSubtreeView ? [rootSubtreeView frame].size : CGSizeZero;
    }
}

- (BOOL) needsGraphLayout
{
    return [[self rootSubtreeView] needsGraphLayout];
}

- (void) setNeedsGraphLayout
{
    [[self rootSubtreeView] recursiveSetNeedsGraphLayout];
}

- (void)collapseRoot
{
    [[self rootSubtreeView] setExpanded:NO];
}

- (void)expandRoot
{
    [[self rootSubtreeView] setExpanded:YES];
}

- (void)toggleExpansionOfSelectedModelNodes:(id)sender
{
    for (id <PSTreeGraphModelNode> modelNode in [self selectedModelNodes]) {
        PSBaseSubtreeView *subtreeView = [self subtreeViewForModelNode:modelNode];
        [subtreeView toggleExpansion:sender];
    }
}

#pragma mark - Scrolling

-(CGRect)boundsOfModelNodes:(NSSet *)modelNodes
{
    CGRect boundingBox = CGRectZero;
    BOOL firstNodeFound = NO;
    for (id <PSTreeGraphModelNode> modelNode in modelNodes) {
        PSBaseSubtreeView *subtreeView = [self subtreeViewForModelNode:modelNode];
        if (subtreeView && (subtreeView.hidden == NO)) {
            UIView *nodeView = [subtreeView nodeView];
            if (nodeView) {
                CGRect rect = [self convertRect:[nodeView bounds] fromView:nodeView];
                if (!firstNodeFound) {
                    
                    boundingBox = rect;
                    firstNodeFound = YES;
                } else {
                    boundingBox = CGRectUnion(boundingBox, rect);
                }
            }
        }
    }
    return boundingBox;
}

- (void)scrollModelNodesToVisible:(NSSet *)modelNodes animated:(BOOL)animated
{
    CGRect targetRect = [self boundsOfModelNodes:modelNodes];
    if (!CGRectIsEmpty(targetRect)) {
        CGFloat padding = [self contentMarigin];
        
        UIScrollView *parentScroll = (UIScrollView *)[self superview];
        if (parentScroll && [parentScroll isKindOfClass:[UIScrollView class]]) {
            targetRect = CGRectInset(targetRect, -padding, -padding);
            [parentScroll scrollRectToVisible:targetRect animated:animated];
        }
    }
}

- (void) scrollSelectedModelNodesToVisbleAnimated:(BOOL)animated
{
    [self scrollModelNodesToVisible:[self selectedModelNodes] animated:animated];
}

#pragma mark - Data Source 

@synthesize modelRoot = modelRoot_;

- (void)setModelRoot:(id<PSTreeGraphModelNode>)newModelRoot
{
    NSParameterAssert(newModelRoot == nil || [newModelRoot conformsToProtocol:@protocol(PSTreeGraphModelNode)]);
    
    if (modelRoot_ != newModelRoot) {
        PSBaseSubtreeView *rootSubtreeView = [self rootSubtreeView];
        [rootSubtreeView removeFromSuperview];
        [modelNodeToSubtreeViewMapTable_ removeAllObjects];
        
        // Discard any previous selection
        [self setSelectedModelNodes:[NSSet set]];
        
        // Switch to new modelRoot
        modelRoot_ = newModelRoot;
        
        // Discard and reload content.
        [self buildGraph];
        [self setNeedsDisplay];
        [[self rootSubtreeView] resursiveSetSubtreeBordersNeedDisplay];
        [self layoutGraphIfNeeded];
        
        // Start with modelRoot selected.
        if (modelRoot_) {
            [self setSelectedModelNodes:[NSSet setWithObject:modelRoot_]];
            [self scrollSelectedModelNodesToVisbleAnimated:NO];
        }
        
    }
}

#pragma mark - Node Hit Testing 

- (id<PSTreeGraphModelNode>)modelNodeAtPoint:(CGPoint)p
{
    PSBaseSubtreeView *rootSubTreeView = [self rootSubtreeView];
    CGPoint subviewPoint = [self convertPoint:p toView:rootSubTreeView];
    id <PSTreeGraphModelNode> hitModelNode = [[self rootSubtreeView] modelNodeAtPoint:subviewPoint];
    return hitModelNode;
}


#pragma mark - Input and Navigation

@synthesize showDetailView = showDetailView_;

- (void)showNodeDetailView
{
    __block BOOL done = YES;
    [UIView animateWithDuration:1.0 animations:^{
        showDetailView_.center = CGPointMake(showDetailView_.center.x - 500., showDetailView_.center.y);
        
    } completion:^(BOOL finished) {
        done = NO;
    }];
    
    while (done == YES) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.00001]];
    }
}

- (void)hideNodeDetailView
{
    __block BOOL done = YES;
    [UIView animateWithDuration:1.0 animations:^{
        showDetailView_.center = CGPointMake(showDetailView_.center.x + 500, showDetailView_.center.y);
    } completion:^(BOOL finished) {
        done = NO;
    }];
    
    while (done == YES) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint viewPonit = [touch locationInView:self];
    
    id <PSTreeGraphModelNode> hitModelNode = [self modelNodeAtPoint:viewPonit];
    if (hitModelNode != Nil) {
        [self showNodeDetailView];
    } else{
        [self hideNodeDetailView];
    }
    [self setSelectedModelNodes:(hitModelNode ? [NSSet setWithObject:hitModelNode] : [NSSet set])];
    [self becomeFirstResponder];
    
}



@end

#pragma mark -
@implementation PSBaseTreeGraphView (Internal)


#pragma mark - ModelNode -> SubtreeView Relationship Management

- (PSBaseSubtreeView *)subtreeViewForModelNode:(id)modelNode
{
    return modelNodeToSubtreeViewMapTable_[modelNode];
}

- (void)setSubtreeView:(PSBaseSubtreeView *)SubtreeView forModelNode:(id)modelNode
{
    modelNodeToSubtreeViewMapTable_[modelNode] = SubtreeView;
}

#pragma mark - Model Tree Navigation

- (BOOL)modelNode:(id<PSTreeGraphModelNode>)modelNode isDescendantOf:(id<PSTreeGraphModelNode>)possibleAncestor
{
    NSParameterAssert(modelNode != nil);
    NSParameterAssert(possibleAncestor != nil);
    
    id <PSTreeGraphModelNode> node = [modelNode parentModeNode];
    while (node != nil) {
        if (node == possibleAncestor) {
            return YES;
        }
        node = [node parentModeNode];
    }
    return NO;
}

- (BOOL)modelNodeIsInAssignedTree:(id<PSTreeGraphModelNode>)modelNode
{
    NSParameterAssert(modelNode != nil);
    
    id <PSTreeGraphModelNode> root = [self modelRoot];
    return (modelNode == root || [self modelNode:modelNode isDescendantOf:root] ? YES : NO);
}

- (id<PSTreeGraphModelNode>)siblingOfModelNode:(id<PSTreeGraphModelNode>)modelNode atRelativeIndex:(NSInteger)relativeIndex
{
    NSParameterAssert(modelNode != nil);
    NSAssert([self modelNodeIsInAssignedTree:modelNode], @"modelNode is not in the tree");
    
    if (modelNode == [self modelRoot]) {
        // modelNode is modelRoot. Disallow traversal to its siblings .
        return nil;
    } else {
        // modelNode is a descendant of modelRoot
        id <PSTreeGraphModelNode> parent = [modelNode parentModeNode];
        NSArray *siblings = [parent childModeNodes];
        
        NSAssert(siblings != nil, @"childModelNodes should return an empty array ,not nil");
        
        if (siblings != nil) {
            NSInteger index = [siblings indexOfObject:modelNode];
            if (index != NSNotFound) {
                index += relativeIndex;
                if (index >= 0 && index < [siblings count]) {
                    return siblings[index];
                }
            }
        }
        return nil;
    }
}



@end
