//
//  MyLeafView.h
//  treeGraph
//
//  Created by lanhu on 14-3-5.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "PSBaseLeafView.h"

@interface MyLeafView : PSBaseLeafView

@property (nonatomic, weak) IBOutlet UIButton *toggleButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *detailLabel;

@end
