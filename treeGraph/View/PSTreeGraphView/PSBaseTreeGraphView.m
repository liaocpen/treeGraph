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
    
}






















@end
