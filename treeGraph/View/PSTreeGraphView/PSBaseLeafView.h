//
//  PSBaseLeafView.h
//  treeGraph
//
//  Created by lanhu on 14-2-13.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Can be a subclass for project specific node view loaded from a nib file.
 */

@interface PSBaseLeafView : UIView

#pragma mark - Styling

@property (nonatomic, strong) UIColor *borderColor;

@property (nonatomic, assign) CGFloat borderWidth;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic, strong) UIColor *selectionColor;


#pragma mark - Selection State

@property (nonatomic, assign, getter = isShowingSelected) BOOL showingSelected;


@end
