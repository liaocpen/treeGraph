//
//  ViewController.m
//  treeGraph
//
//  Created by lanhu on 14-2-12.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "ViewController.h"
#import "PSBaseTreeGraphView.h"
#import "MyLeafView.h"

#import "ObjCClassWrapper.h"

@interface ViewController ()
{
@private
    PSBaseTreeGraphView *__weak treeGraphView_;
    NSString *rootClassName_;
}

@end

@implementation ViewController

#pragma mark - Property Accessors

@synthesize treeGraphView = treeGraphView_;
@synthesize rootClassName = rootClassName_;

- (void)setRootClassName:(NSString *)newRootClassName
{
    NSParameterAssert(newRootClassName != nil);
    
    if (![rootClassName_ isEqualToString:newRootClassName]) {
        rootClassName_ = [newRootClassName copy];
        
        treeGraphView_.connectingLineStyle = 0;
        treeGraphView_.treeGraphOritentation = PSTreeGraphOrientationStyleHorizontal;
        
        [treeGraphView_ setModelRoot:[ObjCClassWrapper wrapperForNamed:rootClassName_]];
    }
}

#pragma mark - View Creation and Initializer

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.treeGraphView setDelegate:self];
    [self.treeGraphView setNodeViewNibName:@"TreeNodeView"];
    [self setRootClassName:@"UIButton"];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.treeGraphView parentClipViewDidResize:nil];
}

#pragma mark - TreeGraph Delegate

- (void)configureNodeView:(UIView *)nodeView withModelNode:(id<PSTreeGraphModelNode>)modelNode
{
    NSParameterAssert(nodeView != nil);
    NSParameterAssert(modelNode != nil);
    ObjCClassWrapper *objectWrapper = (ObjCClassWrapper *)modelNode;
    MyLeafView *leafView = (MyLeafView *)nodeView;
    
    if ([[objectWrapper childModeNodes] count] == 0) {
        [leafView.toggleButton setHidden:YES];
    }
    leafView.titleLabel.text = @"a";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
