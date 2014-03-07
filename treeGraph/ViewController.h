//
//  ViewController.h
//  treeGraph
//
//  Created by lanhu on 14-2-12.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTreeGraphDelegate.h"

@class MyTreeGraphView;

@interface ViewController : UIViewController <PSTreeGraphDelegate>

@property (nonatomic, weak) IBOutlet MyTreeGraphView *treeGraphView;

// the name of the root class that TreeGraph is currently showing.
@property (nonatomic, copy) NSString *rootClassName;

@end
