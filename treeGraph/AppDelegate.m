//
//  AppDelegate.m
//  treeGraph
//
//  Created by lanhu on 14-2-12.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#pragma mark - Internal Interface

@interface AppDelegate ()
{
@private
    UIWindow *window_;
    ViewController *viewController_;
}

@end

@implementation AppDelegate

@synthesize window = window_;
@synthesize viewController = viewController_;

#pragma mark - Application Lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after app lunch.
    [window_ setRootViewController:viewController_];
    [window_ addSubview:viewController_.view];
    [window_ makeKeyAndVisible];
    return  YES;
}

@end
