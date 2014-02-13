//
//  ObjCClassWrapper.h
//  treeGraph
//
//  Created by lanhu on 14-2-12.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSTreeGraphModelNode.h"

@interface ObjCClassWrapper : NSObject <NSCopying, >

#pragma mark - Creating Instances

/**
 *  Return an ObjCClassWrapper for the given Obj-c Class
 *
 *  @param aClass
 *
 *  @return the same ObjCClassWrapper for the given Class.
 */
+ (ObjCClassWrapper *) wrapperForClas:(Class) aClass;

/**
 *  Return an ObjCClassWrapper for the given Obj-c class name .
 *
 *  @param aClassName looking up the class by the given name
 *
 *  @return
 */
+ (ObjCClassWrapper *) wrapperForNamed:(NSString *) aClassName;

#pragma mark - Property Accessors

/**
 *  wrappedClas'name
 */
@property (weak, nonatomic, readonly) NSString *name;

/**
 *  An ObjCClassWrapper repressenting the wrapperClass' superClass
 */
@property (weak, nonatomic, readonly) ObjCClassWrapper *superclassWrapper;

/**
 *  An array of ObjCClassWrapers representing the wrapperClass' subClasses.
 */
@property (weak, nonatomic, readonly) NSArray *subclasses;

/**
 *  Description
 */
@property (nonatomic, readonly) size_t wrappedClassInstanceSize;








@end
