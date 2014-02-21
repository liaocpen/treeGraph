//
//  PSBaseTreeGraphView.h
//  treeGraph
//
//  Created by Liao_Cpen on 14-2-13.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A TreeGraph's nodes may be connected by either "direct" or "orthogonal" lines.
 */

typedef enum PSTreeGraphConnectingLineStyle : NSUInteger {
    PSTreeGraphConnectingLineStyleDirect = 0,
    PSTreeGraphConnectingLineStyleOrthogonal = 1,
} PSTreeGraphConnectingLineStyle;

/**
 *  A TreeGraph's orientation may be either "horizontal" or "vertical".
 */

typedef enum PSTreeGraphOrientationStyle : NSUInteger {
    PSTreeGraphOrientationStyleHorizontal = 0,
    PSTreeGraphOrientationStyleVertical = 1,
    PSTreeGraphOrientationStyleHorizontalFlipped = 2,
    PSTreeGraphOrientationStyleVerticalFlipped = 3,
} PSTreeGraphOrientationStyle;

@class PSBaseSubtreeView;

@protocol PSTreeGraphModelNode;
@protocol PSTreeGraphDelegate;


@interface PSBaseTreeGraphView : UIView <UIKeyInput>

#pragma mark - Delegate

@property (nonatomic, weak) id <PSTreeGraphDelegate> delegate;

#pragma mark - Parent Resize Notification

/**
 *  keep the View in sync for now.
 */
- (void) parentClipViewDidResize:(id) object;

#pragma mark - Creating Instances

/**
 *  Initializes a new TreeGraph Instances
 */

- (id)initWithFrame:(CGRect)frame;

#pragma mark - Connection to Model

/**
 *  The root of the model node tree that the TreeGraph is being asked to display
 */
@property (nonatomic, strong) id <PSTreeGraphModelNode> modelRoot;

#pragma mark - Root SubtreeView Access

/**
 *  A TreeGraph builds the tree it displays using recursively nested SubtreeView instances.
 */
@property (weak, nonatomic, readonly) PSBaseSubtreeView *rootSubtreeView;

#pragma mark - Node View Nib Specification

/**
 *  The Name of the .nib file from which to instantiate node Views.
 */
@property (nonatomic, copy) NSString *nodeViewNibName;

#pragma mark - Selection State 

/**
 *  The unordered set of model nodes that are currently selected in the TreeGraph.
 *  @note Every member of this set must be a descendant of the TreeGraph's modelRoot(or modelRoot itself).
 */
@property (nonatomic, copy) NSSet *selectedModelNodes;

/**
 *  return the selected node, if exactly one node is currently selected. 
 *  @note Return nil if zero, or more than one, nodes are currently selected.
 */
@property (weak, nonatomic, readonly) id <PSTreeGraphModelNode> singleSelectedModelNode;


/**
 *  Return the bounding box of the selectedModelNodes.
 */
@property (nonatomic, readonly) CGRect selectionBounds;


#pragma mark - Node Hit

/**
 *  return the model node under the given point, which must be expressed in the TreeGraph's interior coordinate space.
 */
- (id <PSTreeGraphModelNode>) modelNodeAtPoint: (CGPoint)p;

#pragma mark - Sizing and Layout

/**
 *  A TreeGraph's minimumFrameSize is the size needed to accommodate its content and margins.
 */
@property (nonatomic, assign) CGSize minimumFrameSize;

// If YES, and if the TreeGraph is the documentView of an UIScrollView, the TreeGraph will
/// automatically resize itself as needed to ensure that it always at least fills the content
/// area of its enclosing UIScrollView.  If NO, or if the TreeGraph is not the documentView of
/// an UIScrollView, the TreeGraph's size is determined only by its content and margins.

@property (nonatomic, assign) BOOL resizesToFillEnclosingScrollView;

/**
 *  The style for tree graph orientation
 */
@property (nonatomic, assign) PSTreeGraphOrientationStyle treeGraphOritentation;

/**
 *  The TreeGraoh is flipped. Default is No.
 */
@property (nonatomic, assign) BOOL treeGraphFlipped;

/**
 *  @return Yes if the tree needs relayout
 */
- (BOOL) needsGraphLayout;

/**
 *  Marks the tree as needing relayout
 */
- (void) setNeedsGraphLayout;

/**
 *  Performs graph layout, if the tree is marked as needing it.
 *
 *  @return the size computed for the tree
 */
- (CGSize) layoutGraphIfNeeded;

/**
 *  Collapses the root node , if it is currently expanded.
 */
- (void) collapseRoot;

/**
 *  Expands the root node , if it is currently collapsed.
 */
- (void) expandRoot;

/**
 *  Toggle the expansion state of the TreeGraph's selectedModelNodes,expanding those that are currently collapsed, and collapsing those that are currently expandad.
 */
- (IBAction) toggleExpansionOfSelectedModelNodes:(id)sender;

/**
 *  @return the bounding box of the node view  that represent the specified mode Nodes.
 */
- (CGRect) boundsOfModelNodes: (NSSet *)modelNodes;


#pragma mark -Scrolling

- (void) scrollModelNodesToVisible:(NSSet *)modelNodes animated:(BOOL)animated;

- (void) scrollSelectedModelNodesToVisbleAnimated:(BOOL)animated;


#pragma mark - Animation Support

/**
 *  Defaults to YES
 */
@property (nonatomic, assign) BOOL animatesLayout;

/// Used to temporarily suppress layout animation during event tracking.  Layout animation happens
/// only if animatesLayout is YES and this is NO.

@property (nonatomic, assign) BOOL layoutAnimationSuppressed;


#pragma mark - Layout Metrics

@property (nonatomic, assign) CGFloat contentMarigin;

/**
 *  The horizonal spacing between each parent node and its child nodes
 */
@property (nonatomic, assign) CGFloat parentChildSpacing;

/**
 *  The vertical spacing between sibling nodes.
 */
@property (nonatomic, assign) CGFloat siblingSpacing;


#pragma mark - Styling 

@property (nonatomic, strong) UIColor *connectingLineColor;

@property (nonatomic, assign) CGFloat connectingLineWidth;

@property (nonatomic, assign) PSTreeGraphConnectingLineStyle connectingLineStyle;


/// Defaults to NO.  If YES, a stroked outline is shown around each of the TreeGraph's
/// SubtreeViews.  This can be helpful for visualizing the TreeGraph's structure and layout.

@property (nonatomic, assign) BOOL showSubtreeFrames;



#pragma mark - Input and Navigation


































@end
