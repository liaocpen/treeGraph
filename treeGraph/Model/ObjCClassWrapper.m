//
//  ObjCClassWrapper.m
//  treeGraph
//
//  Created by lanhu on 14-2-12.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "ObjCClassWrapper.h"
#import <objc/runtime.h>

static NSMutableDictionary *classToWrapperMapTable = nil;
static NSMutableDictionary *jsonToWrapperMapTable = nil;

/**
 *  Compares two ObjCClassWrappers by name
 *  @return an NSComparisonResult
 */
//static NSInteger CompareClassNames(id classA, id classB, void* context)
//{
//    return [[classA description] compare:[classB description]];
//}

@interface ObjCClassWrapper ()
{
    @private
   // Class wrappedClass;
    NSString *wrappedJson;
    NSDictionary *wrappedData;
    NSMutableArray *subclassCache;
}

@end

@implementation ObjCClassWrapper

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


#pragma mark - Creating Instances

//- initWithWrappedClass: (Class)aClass
//{
//    self = [super init];
//    if (self) {
//        if (aClass != nil) {
//            wrappedClass = aClass;
//            if (classToWrapperMapTable == nil) {
//                classToWrapperMapTable = [NSMutableDictionary dictionaryWithCapacity:16];
//            }
//            classToWrapperMapTable[(id<NSCopying>)wrappedClass] = self;
//        } else {
//            return nil;
//        }
//    }
//    return  self;
//}

- (id)initWithWrappedJson: (NSString *)aJsonID
{
    self = [super init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"a.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];

    if (self) {
        if (aJsonID != nil) {
           // wrappedClass = [[ObjCClassWrapper alloc] init];
            wrappedJson = aJsonID;
            if (jsonToWrapperMapTable == nil) {
                jsonToWrapperMapTable = [NSMutableDictionary dictionaryWithCapacity:16];
            }
            jsonToWrapperMapTable[(id<NSCopying>)wrappedJson] = self;
            wrappedData = jsonObject;
        }else {
            return nil;
        }
    }
    return self;
}

//+ (ObjCClassWrapper *) wrapperForClas:(Class)aClass
//{
//    ObjCClassWrapper *wrapper = classToWrapperMapTable[aClass];
//    if (wrapper == nil) {
//        wrapper = [[self alloc] initWithWrappedClass:aClass];
//    }
//    return wrapper;
//}

+ (ObjCClassWrapper *) wrapperForNamed:(NSString *)aClassName
{
    return [self wrapperForClas:NSClassFromString(aClassName)];
}

+ (ObjCClassWrapper *) wrapperforJson: (NSString *)jsonID
{
    ObjCClassWrapper *wrapper = jsonToWrapperMapTable[jsonID];
    if (wrapper == nil) {
        wrapper = [[self alloc] initWithWrappedJson:jsonID];
    }
    return wrapper;
}

#pragma mark - Property Accessors

//- (NSString *)name
//{
//    return NSStringFromClass(wrappedClass);
//}

//- (NSString *)description
//{
//    return [self name];
//}

//- (size_t) wrappedClassInstanceSize
//{
//    return class_getInstanceSize(wrappedClass);
//}

- (ObjCClassWrapper *) superclassWrapper
{
    //return [[self class] wrapperForClas:class_getSuperclass(wrappedClass)];
   // return [[self class] wrapperforJson:<#(NSString *)#>]
    return nil;
}


- (NSArray *) subclasses
{
    if (subclassCache == nil) {
        subclassCache = [[NSMutableArray alloc] init];
        NSDictionary *jsonData = wrappedData;
        jsonData = [jsonData objectForKey:@"children"];
        for (NSDictionary *a in jsonData) {
            if (![a objectForKey:@"leaf"]) {
                [subclassCache addObject:[[self class] wrapperforJson:[a objectForKey:@"name"]]];
                
            }
        }
    }
    return subclassCache;
//    if (subclassCache == nil) {
//        int i;
//        int numClasses = 0;
//        int newNumClasses = objc_getClassList(NULL, 0);
//        Class *classes = NULL;
//        while (numClasses < newNumClasses) {
//            numClasses = newNumClasses;
//            classes = (Class*)realloc(classes, sizeof(classes)* numClasses);
//            newNumClasses = objc_getClassList(classes, numClasses);
//        }
//        
//        subclassCache = [[NSMutableArray alloc] initWithCapacity:numClasses];
//        for (i = 0; i < numClasses; i++) {
//            if (class_getSuperclass(classes[i]) == wrappedClass) {
//                [subclassCache addObject:[[self class] wrapperForClas:classes[i]]];
//            }
//        }
//        free(classes);
//        [subclassCache sortUsingFunction:CompareClassNames context:NULL];
//        
//    }
//    return subclassCache;
}


#pragma mark - TreeGraphModelNode Protocol

- (id<PSTreeGraphModelNode>)parentModeNode
{
    return [self superclassWrapper];
}

- (NSArray *)childModeNodes
{
    return [self subclasses];
}




@end
