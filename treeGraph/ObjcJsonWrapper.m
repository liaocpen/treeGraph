//
//  ObjcJsonWrapper.m
//  treeGraph
//
//  Created by lanhu on 14-3-19.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "ObjcJsonWrapper.h"
#import <objc/runtime.h>

static NSMutableDictionary *jsonToWrapperMapTable = nil;

@interface ObjcJsonWrapper ()
{
@private
    NSString *wrapperedID;
    NSString *pID;
    NSMutableArray *subWrapperCache;
}

@end

@implementation ObjcJsonWrapper

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - Creating Instances

- (id)initWithWrapperID:(NSString *)aWrapperID pid:(NSString *)aPid
{
    self = [super init];
    if (self) {
        if (aWrapperID != nil) {
            wrapperedID = aWrapperID;
            pID = aPid;
            if (jsonToWrapperMapTable == nil) {
                jsonToWrapperMapTable = [NSMutableDictionary dictionaryWithCapacity:16];
            }
            jsonToWrapperMapTable[(id<NSCopying>)aWrapperID] = self;
        }else {
            return nil;
        }
    }
    return self;
}

+ (ObjcJsonWrapper *)wrapperForJson:(NSDictionary *)ajsonData
{
    NSString *jsonID = [ajsonData objectForKey:@"id"];
    NSString *pid = [ajsonData objectForKey:@"pid"];
    ObjcJsonWrapper *wrapper = jsonToWrapperMapTable[jsonID];
    if (wrapper == nil) {
        wrapper = [[self alloc] initWithWrapperID:jsonID pid:pid];
        wrapper.jsonData = [NSMutableDictionary dictionaryWithDictionary:ajsonData];
    }
    return wrapper;
}

#pragma mark - Add Child Data

- (void)addChildWrapper:(NSDictionary *)newData
{
    
    NSArray *childrenArray = [self.jsonData objectForKey:@"children"];
    NSMutableArray *newChild = [[NSMutableArray alloc] init];
    [newChild addObject:newData];
    [newChild addObjectsFromArray:childrenArray];
    [self.jsonData setValue:newChild forKey:@"children"];
}


#pragma mark - Property Accessors

- (NSString *)name
{
    return [self.jsonData objectForKey:@"name"];
}

- (ObjcJsonWrapper *) superWrapper
{
    ObjcJsonWrapper *pWrapper = jsonToWrapperMapTable[pID];
    if (pWrapper != nil) {
        return pWrapper;
    }
    return nil;
}

- (NSArray *)subWrapper
{
    if (subWrapperCache == nil) {
        subWrapperCache = [[NSMutableArray alloc] init];
        NSDictionary *subData = [self.jsonData objectForKey:@"children"];
        for (NSDictionary *temp in subData) {
            [subWrapperCache addObject:[[self class] wrapperForJson:temp]];
        }
    }
    return subWrapperCache;
}

#pragma mark - TreeGraphModel Protocol

- (id<PSTreeGraphModelNode>)parentModeNode
{
    return [self superWrapper];
}

- (NSArray *)childModeNodes{
    return [self subWrapper];
}
@end
