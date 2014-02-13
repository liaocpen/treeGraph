//
//  PSBaseLeafView.m
//  treeGraph
//
//  Created by lanhu on 14-2-13.
//  Copyright (c) 2014年 lanhu. All rights reserved.
//

#import "PSBaseLeafView.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - Internal Interface 

@interface PSBaseLeafView ()
{

}

- (void) updateLayerAppearanceToMatchContainerView;
- (void) configureDetaults;

@end

@implementation PSBaseLeafView

#pragma mark - Styling 

-(void) setBorderColor:(UIColor *)color
{
    if (_borderColor != color) {
        _borderColor = color;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

-(void) setBorderWidth:(CGFloat)width
{
    if (_borderWidth != width) {
        _borderWidth = width;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

-(void) setCornerRadius:(CGFloat)radius
{
    if (_cornerRadius != radius) {
        _cornerRadius = radius;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

-(void) setFillColor:(UIColor *)color
{
    if (_fillColor != color) {
        _fillColor = color;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

-(void) setSelectionColor:(UIColor *)color
{
    if (_selectionColor != color) {
        _selectionColor = color;
        [self updateLayerAppearanceToMatchContainerView];
    }
}

#pragma mark - Selection State

-(void) setShowingSelected:(BOOL)newShowingSelected
{
    if (_showingSelected != newShowingSelected) {
        _showingSelected = newShowingSelected;
        [self updateLayerAppearanceToMatchContainerView];
    }
}


#pragma mark - Update Layer
-(void) updateLayerAppearanceToMatchContainerView
{
    CGFloat scaleFactor = 1.0f;
    CALayer *layer = [self layer];
    
    [layer setBorderWidth:(_borderWidth * scaleFactor)];
    
    if (_borderWidth > 0.0f) {
        [layer setBorderColor:[_borderColor CGColor]];
    }
    
    [layer setCornerRadius:(_cornerRadius * scaleFactor)];
    
    if (_showingSelected) {
        [layer setBackgroundColor:[[self selectionColor] CGColor]];
    } else {
        [layer setBackgroundColor:[[self fillColor] CGColor]];
    }
}


#pragma mark - Initialization

-(void) configureDetaults
{
    _borderColor = [UIColor colorWithRed:1.0 green:0.8 blue:0.4 alpha:1.0];
    _borderWidth = 3.0;
    _cornerRadius = 8.0;
    _fillColor = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0];
    _selectionColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0];
    _showingSelected = NO;
}

#pragma mark - UIView

-(id)initWithFrame:(CGRect)newFrame
{
    self = [super initWithFrame:newFrame];
    if (self) {
        [self configureDetaults];
        [self updateLayerAppearanceToMatchContainerView];
    }
    return self;
}

#pragma mark - NSCoding

- (void) encodeWithCoder:(NSCoder *)enCoder
{
    [super encodeWithCoder:enCoder];
    [enCoder encodeObject:_borderColor forKey:@"borderColor"];
    [enCoder encodeFloat:_borderWidth forKey:@"borderWidth"];
    [enCoder encodeFloat:_cornerRadius forKey:@"cornerRadius"];
    [enCoder encodeObject:_fillColor forKey:@"fillColor"];
    [enCoder encodeObject:_selectionColor forKey:@"selectionColor"];
    [enCoder encodeBool:_showingSelected forKey:@"showingSelected"];
}

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self configureDetaults];
        
        if ([decoder containsValueForKey:@"borderColor"]) {
            _borderColor = [decoder decodeObjectForKey:@"borderColor"];
        }
        if ([decoder containsValueForKey:@"borderWidth"])
            _borderWidth = [decoder decodeFloatForKey:@"borderWidth"];
        if ([decoder containsValueForKey:@"cornerRadius"])
            _cornerRadius = [decoder decodeFloatForKey:@"cornerRadius"];
        if ([decoder containsValueForKey:@"fillColor"])
            _fillColor = [decoder decodeObjectForKey:@"fillColor"];
        if ([decoder containsValueForKey:@"selectionColor"])
            _selectionColor = [decoder decodeObjectForKey:@"selectionColor"];
        if ([decoder containsValueForKey:@"showingSelected"])
            _showingSelected = [decoder decodeBoolForKey:@"showingSelected"];
        
        [self updateLayerAppearanceToMatchContainerView];
    }
    return self;
}




@end
