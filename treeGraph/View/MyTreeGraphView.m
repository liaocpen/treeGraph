//
//  MyTreeGraphView.m
//  treeGraph
//
//  Created by lanhu on 14-3-5.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "MyTreeGraphView.h"
#import "ObjCClassWrapper.h"

@interface MyTreeGraphView ()
{
    
}

@end

@implementation MyTreeGraphView


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configDetailView];
    }
    return self;
}

- (void)configDetailView
{
    _nodeName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 100)];
    [self.showDetailView addSubview:_nodeName];
    
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ObjCClassWrapper *wrapper = (ObjCClassWrapper *)[self singleSelectedModelNode];
    _nodeName.text = wrapper.name;
}

@end
