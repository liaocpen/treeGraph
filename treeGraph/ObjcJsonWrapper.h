//
//  ObjcJsonWrapper.h
//  treeGraph
//
//  Created by lanhu on 14-3-19.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSTreeGraphModelNode.h"

@interface ObjcJsonWrapper : NSObject <NSCopying, PSTreeGraphModelNode>

#pragma mark - Creating Instances

+ (ObjcJsonWrapper *) wrapperForJson: (NSDictionary *)jsonData;


#pragma mark - Property Accessors

@property (weak, nonatomic, readonly) NSString *name;

@property (strong, nonatomic) NSDictionary *jsonData;

@property (weak, nonatomic, readonly) ObjcJsonWrapper *superWrapper;

@property (weak, nonatomic, readonly) NSArray *subWrapper;

@end
