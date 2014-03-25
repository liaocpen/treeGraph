//
//  MyTreeGraphView.m
//  treeGraph
//
//  Created by lanhu on 14-3-5.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "MyTreeGraphView.h"
#import "ObjcJsonWrapper.h"
#import "PSBaseSubtreeView.h"

@interface MyTreeGraphView ()
{
    NSInteger tmp;
}

@end

@implementation MyTreeGraphView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configDetailView];
        tmp = 1;
    }
    return self;
}

- (void)configDetailView
{
    _nodeName = [[UILabel alloc] initWithFrame:CGRectMake(10, 300, 100, 100)];
    [self.showDetailView addSubview:_nodeName];
    
    UIButton * _addbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_addbtn setFrame:CGRectMake(10, 150, 70, 40)];
    [_addbtn setTitle:@"添加孩子" forState:UIControlStateNormal];
    [_addbtn addTarget:self action:@selector(addChild) forControlEvents:UIControlEventTouchDown];
    [self.showDetailView addSubview:_addbtn];
}

#pragma mark - Custom Method

- (void)addChild
{
    ObjcJsonWrapper *wrapper = (ObjcJsonWrapper*)[self singleSelectedModelNode];
    NSDictionary *a = @{@"name": @"avc", @"id": [NSString stringWithFormat:@"%d", ++tmp] , @"pid": [wrapper.jsonData objectForKey:@"id"]};
    [wrapper addChildWrapper:a];
    [wrapper clearChildCache];
    [self setModelRoot:[self modelRoot]];
}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    ObjcJsonWrapper *wrapper = (ObjcJsonWrapper *)[self singleSelectedModelNode];
    _nodeName.text = wrapper.name;
}



@end
