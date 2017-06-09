//
//  QBRefreshConst.h
//  刷新动画控件制作
//
//  Created by lizhihui on 16/7/22.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <objc/message.h>
// 常量
UIKIT_EXTERN const CGFloat QBRefreshHeaderHeight;
UIKIT_EXTERN const CGFloat QBRefreshMaxOffset;//!<scrollview最大偏移量,小于等于0表示不设置.
UIKIT_EXTERN const CGFloat QBRefreshHeaderHeight_increment;//!<增量.
UIKIT_EXTERN const CGFloat QBRefreshFastAnimationDuration;
UIKIT_EXTERN const CGFloat QBRefreshSlowAnimationDuration;

UIKIT_EXTERN NSString *const QBRefreshKeyPathContentOffset;
UIKIT_EXTERN NSString *const QBRefreshKeyPathContentSize;
UIKIT_EXTERN NSString *const QBRefreshKeyPathContentInset;
UIKIT_EXTERN NSString *const QBRefreshKeyPathPanState;

// 状态检查
#define QBRefreshCheckState \
QBRefreshState oldState = self.state; \
[super setState:state];
