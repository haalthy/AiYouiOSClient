//
//  UIView+WZLBadge.m
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/6/24.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//

#import "UIView+WZLBadge.h"
#import <objc/runtime.h>
#import "UIView+Frame.h"
#import "CAAnimation+WAnimation.h"

//key for associative methods during runtime
static char badgeLabelKey;
static char badgeBgColorKey;
static char badgeTextColorKey;
static char badgeAniTypeKey;
static char badgeFrameJey;
static char badgeShowKey;

#define kBadgeBreatheAniKey     @"breathe"
#define kBadgeRotateAniKey      @"rotate"
#define kBadgeShakeAniKey       @"shake"
#define kBadgeScaleAniKey       @"scale"

@implementation UIView (WZLBadge)


#pragma mark -- public methods
/**
 *  show badge with red dot style and WBadgeAnimTypeNone by default.
 */
- (void)showBadgeWithShowType:(WBadgeShowStyle)showStyle
{
    [self showBadgeWithStyle:WBadgeStyleRedDot showType:WBadgeShowStyleUp value:0 animationType:WBadgeAnimTypeNone showLocationType:showStyle];
}

/**
 *  showBadge
 *
 *  @param style WBadgeStyle type
 *  @param value (if 'style' is WBadgeStyleRedDot or WBadgeStyleNew, 
 *                this value will be ignored. In this case, any value will be ok.)
 */
- (void)showBadgeWithStyle:(WBadgeStyle)style showType:(WBadgeShowStyle)showType value:(NSInteger)value animationType:(WBadgeAnimType)aniType showLocationType:(WBadgeShowStyle)showStyle
{
    self.aniType = aniType;
    self.showType = showStyle;
    
    switch (style) {
        case WBadgeStyleRedDot:
            [self showRedDotBadge];
            break;
        case WBadgeStyleNumber:
            [self showNumberBadgeWithValue:value];
            break;
        case WBadgeStyleNew:
            [self showNewBadge];
            break;
        default:
            break;
    }
    if (aniType != WBadgeAnimTypeNone) {
        [self beginAnimation];
    }
}

/**
 *  clear badge
 */
- (void)clearBadge
{
    self.badge.hidden = YES;
}



#pragma mark -- private methods
- (void)showRedDotBadge
{
    [self badgeInit];
    //if badge has been displayed and, in addition, is was not red dot style, we must update UI.
    if (self.badge.tag != WBadgeStyleRedDot) {
        self.badge.text = @"";
        self.badge.tag = WBadgeStyleRedDot;
        self.badge.layer.cornerRadius = self.badge.width / 2;
    }
    self.badge.hidden = NO;
}

- (void)showNewBadge
{
    [self badgeInit];
    //if badge has been displayed and, in addition, is was not red dot style, we must update UI.
    if (self.badge.tag != WBadgeStyleNew) {
        self.badge.text = @"new";
        self.badge.tag = WBadgeStyleNew;
        self.badge.width = 20;
        self.badge.height = 13;
        
        // 红点显示位置
        CGFloat pointY = [self showBadgeTypeWithStyle:self.showType];
        
        self.badge.center = CGPointMake(self.width, pointY);
        self.badge.font = [UIFont boldSystemFontOfSize:9];
        self.badge.layer.cornerRadius = self.badge.height / 3;
    }
    self.badge.hidden = NO;
}

- (void)showNumberBadgeWithValue:(NSInteger)value
{
    if (value < 0) {
        return;
    }
    [self badgeInit];
    if (self.badge.tag != WBadgeStyleNumber) {
        self.badge.tag = WBadgeStyleNumber;
        
        //maximun value allowed is 99. When the value is greater than 99, "99+" will be shown.
        if (value >=100) {
            self.badge.text = @"99+";
        } else {
            self.badge.text = [NSString stringWithFormat:@"%@", @(value)];
        }
        [self adjustLabelWidth:self.badge];
        self.badge.width = self.badge.width - 4;
        self.badge.height = 12;
        if (self.badge.width < self.badge.height) {
            self.badge.width = self.badge.height;
        }
        
        // 红点显示位置
        CGFloat pointY = [self showBadgeTypeWithStyle:self.showType];
        
        self.badge.center = CGPointMake(self.width, pointY);
        self.badge.font = [UIFont boldSystemFontOfSize:9];
        self.badge.layer.cornerRadius = self.badge.height / 2;
    }
    self.badge.hidden = NO;
}

//lazy loading
- (void)badgeInit
{
    if (self.badgeBgColor == nil) {
        self.badgeBgColor = [UIColor redColor];
    }
    if (self.badgeTextColor == nil) {
        self.badgeTextColor = [UIColor whiteColor];
    }
    if (nil == self.badge) {
        CGFloat redotWidth = 8;
        CGRect frame = (CGRect){CGPointZero, redotWidth, redotWidth};
        self.badge = [[UILabel alloc] initWithFrame:frame];
        self.badge.textAlignment = NSTextAlignmentCenter;
        
        // 红点显示位置
        CGFloat pointY = [self showBadgeTypeWithStyle:self.showType];
        
        self.badge.center = CGPointMake(self.width, pointY);
        self.badge.backgroundColor = self.badgeBgColor;
        self.badge.textColor = self.badgeTextColor;
        self.badge.text = @"";
        self.badge.tag = WBadgeStyleRedDot;//red dot by default
        self.badge.layer.cornerRadius = self.badge.width / 2;
        self.badge.layer.masksToBounds = YES;//very important
        [self addSubview:self.badge];
    }
}

#pragma mark - 红点等显示位置

- (CGFloat)showBadgeTypeWithStyle:(WBadgeShowStyle)showStyle {

    switch (self.showType) {
        case WBadgeShowStyleMiddle:
            return self.height / 2;
            break;
        case WBadgeShowStyleUp:
            return 0;
            break;
 
        case WBadgeShowStyleNone:
            return 0;
            break;
        default:
            return 0;
            break;
    }
}

#pragma mark --  other private methods
- (void)adjustLabelWidth:(UILabel *)label
{
    [label setNumberOfLines:0];
    NSString *s = label.text;
    UIFont *font = [UIFont fontWithName:@"Arial" size:label.font.pointSize];
    CGSize size = CGSizeMake(320,2000);
    NSDictionary *attribute = @{NSFontAttributeName: font};
    CGSize labelsize = [s boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine attributes:attribute context:nil].size;
    CGRect frame = label.frame;
    frame.size = labelsize;
    [label setFrame:frame];
}

#pragma mark -- animation

//if u want to add badge animation type, follow steps bellow:
//1. go to definition of WBadgeAnimType and add new type
//2. go to category of CAAnimation+WAnimation to add new animation interface
//3. call that new interface here
- (void)beginAnimation
{
    if (self.aniType == WBadgeAnimTypeBreathe)
    {
        [self.badge.layer addAnimation:[CAAnimation opacityForever_Animation:1.4]
                                forKey:kBadgeBreatheAniKey];
    }
     else if (self.aniType == WBadgeAnimTypeShake)
    {
        [self.badge.layer addAnimation:[CAAnimation shake_AnimationRepeatTimes:MAXFLOAT
                                                                      durTimes:1
                                                                        forObj:self.badge.layer]
                                forKey:kBadgeShakeAniKey];
    }
    else if (self.aniType == WBadgeAnimTypeScale)
    {
        [self.badge.layer addAnimation:[CAAnimation scaleFrom:1.4
                                                      toScale:0.6
                                                     durTimes:1
                                                          rep:MAXFLOAT]
                                forKey:kBadgeScaleAniKey];
    }
}


#pragma mark -- setter/getter
- (UILabel *)badge
{
    return objc_getAssociatedObject(self, &badgeLabelKey);
}

- (void)setBadge:(UILabel *)label
{
    objc_setAssociatedObject(self, &badgeLabelKey, label, OBJC_ASSOCIATION_RETAIN);
}

- (UIColor *)badgeBgColor
{
    return objc_getAssociatedObject(self, &badgeBgColorKey);
}

- (void)setBadgeBgColor:(UIColor *)badgeBgColor
{
    objc_setAssociatedObject(self, &badgeBgColorKey, badgeBgColor, OBJC_ASSOCIATION_RETAIN);
}

- (UIColor *)badgeTextColor
{
    return objc_getAssociatedObject(self, &badgeTextColorKey);
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    objc_setAssociatedObject(self, &badgeTextColorKey, badgeTextColor, OBJC_ASSOCIATION_RETAIN);
}

- (WBadgeAnimType)aniType
{
    id obj = objc_getAssociatedObject(self, &badgeAniTypeKey);
    if(obj != nil && [obj isKindOfClass:[NSNumber class]])
    {
        return [obj integerValue];
    }
    else
        return WBadgeAnimTypeNone;
}

- (void)setAniType:(WBadgeAnimType)aniType
{
    NSNumber *numObj = @(aniType);
    objc_setAssociatedObject(self, &badgeAniTypeKey, numObj, OBJC_ASSOCIATION_RETAIN);
}

- (WBadgeShowStyle)showType {

    id obj = objc_getAssociatedObject(self, &badgeShowKey);
    if (obj != nil && [obj isKindOfClass:[NSNumber class]]) {
        return [obj integerValue];
    }
    else {
    
        return WBadgeShowStyleNone;
    }
}

- (void)setShowType:(WBadgeShowStyle)showType {

    NSNumber *numObj = @(showType);
    objc_setAssociatedObject(self, &badgeShowKey, numObj, OBJC_ASSOCIATION_RETAIN);
}

- (CGRect)badgeFrame
{
    id obj = objc_getAssociatedObject(self, &badgeFrameJey);
    if (obj != nil && [obj isKindOfClass:[NSArray class]] && [obj count] == 4 ) {
        CGFloat x = [obj[0] floatValue];
        CGFloat y = [obj[1] floatValue];
        CGFloat width = [obj[2] floatValue];
        CGFloat height = [obj[3] floatValue];
        return  CGRectMake(x, y, width, height);
    } else
        return CGRectZero;
}

- (void)setBadgeFrame:(CGRect)badgeFrame
{
    
}



@end
