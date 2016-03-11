//
//  UIView+WZLBadge.h
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/6/24.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//  Project description: this is a solution to enable any UIView to display badge

#import <UIKit/UIKit.h>

#pragma mark -- types definition

typedef NS_ENUM(NSUInteger, WBadgeStyle)
{
    WBadgeStyleRedDot = 0,          /* red dot style */
    WBadgeStyleNumber,              /* badge with number */
    WBadgeStyleNew                  /* badge with a fixed text "new" */
};

typedef NS_ENUM(NSUInteger, WBadgeAnimType)
{
    WBadgeAnimTypeNone = 0,         /* without animation, badge stays still */
    //WBadgeAnimTypeRotate,           /* rotate effect */
    WBadgeAnimTypeScale,
    WBadgeAnimTypeShake,            /* shake around top anchor point */
    WBadgeAnimTypeBreathe           /* breathing light effect, which makes badge more apparent */
};

typedef NS_ENUM(NSInteger, WBadgeShowStyle) {

    WBadgeShowStyleNone = 0,
    WBadgeShowStyleUp,
    WBadgeShowStyleMiddle
};


#pragma mark -- badge apis

@interface UIView (WZLBadge)

@property (nonatomic, strong) UILabel *badge;
@property (nonatomic, strong) UIColor *badgeBgColor;    /* red color by default if not set */
@property (nonatomic, strong) UIColor *badgeTextColor;  /* white color by default if not set */
@property (nonatomic, assign) CGRect badgeFrame;        /* we have optimized the badge frame. 
                                                         This property is adviced not to set manually */
@property (nonatomic, assign) WBadgeAnimType aniType;   /* NOTE that this is not animation type of badge's
                                                            appearing nor  hidding*/

@property (nonatomic, assign) WBadgeShowStyle showType;

/**
 *  show badge with red dot style and WBadgeAnimTypeNone by default.
 */
- (void)showBadgeWithShowType:(WBadgeShowStyle)showStyle;

/**
 *  showBadge
 *
 *  @param style WBadgeStyle type
 *  @param value (if 'style' is WBadgeStyleRedDot or WBadgeStyleNew, this value will be ignored. In this case, any value will be ok.)
*   @param aniType
 */
- (void)showBadgeWithStyle:(WBadgeStyle)style showType:(WBadgeShowStyle)showType value:(NSInteger)value animationType:(WBadgeAnimType)aniType showLocationType:(WBadgeShowStyle)showStyle;


/**
 *  clear badge
 */
- (void)clearBadge;

@end
