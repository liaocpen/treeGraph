//
//  MyTreeGraphView.h
//  treeGraph
//
//  Created by lanhu on 14-3-5.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "PSBaseTreeGraphView.h"

@interface MyTreeGraphView : PSBaseTreeGraphView

@property (nonatomic, weak) IBOutlet UIButton *expandButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;
@end
