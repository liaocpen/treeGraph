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
    UIView *inputView_;
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
    if (connectingLineWidth_ != newContentMarigin) {
        connectingLineWidth_ = newContentMarigin;
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
    
    if (inputView_ == nil) {
        inputView_ = [[UIView alloc] initWithFrame:CGRectZero];
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
        NSMutableSet *intersectionSet = [selectedModelNodes_ mutableCopy];
        //交集
        [intersectionSet intersectSet:newSelectedModelNodes];

        NSMutableSet *differenceSet = [combineSet mutableCopy];
        //交集的补集
        [differenceSet minusSet:intersectionSet];
    }
}


@end
