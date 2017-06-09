//
//  QBRefreshComponent.h
//  刷新动画控件制作
//
//  Created by lizhihui on 16/7/22.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBRefreshConst.h"

/** 刷新控件的状态 */
typedef NS_ENUM(NSInteger, QBRefreshState) {
    /** 初始状态 */
    QBRefreshState_initial = 1,
    /**正在下拉的状态*/
    QBRefreshState_pulling,
    /** (符合刷新条件)即将刷新的状态 */
    QBRefreshState_will_refreshing,
    /** 正在刷新中的状态 */
    QBRefreshState_refreshing,
    /** 刷新完毕状态 */
    QBRefreshState_end,
};

/** 进入刷新状态的回调 */
typedef void (^QBRefreshingBlock)();

@interface QBRefreshComponent : UIView {
    /** 记录scrollView刚开始的inset */
    UIEdgeInsets _scrollViewOriginalInset;
    /** 父控件 */
    __weak UIScrollView *_scrollView;
}
#pragma mark - 刷新回调
/** 刷新回调 */
@property (copy, nonatomic) QBRefreshingBlock refreshingBlock;
/** 触发回调（交给子类去调用） */
- (void)executeRefreshingCallback;

#pragma mark - 刷新状态控制
/** 进入刷新状态 */
- (void)beginRefreshing;
/** 结束刷新状态 */
- (void)endRefreshing;
/** 是否正在刷新 */
- (BOOL)isRefreshing;
/** 刷新状态 一般交给子类内部实现 */
@property (assign, nonatomic) QBRefreshState state;

#pragma mark - 交给子类去访问
/** 记录scrollView刚开始的inset */
@property (assign, nonatomic, readonly) UIEdgeInsets scrollViewOriginalInset;
/** 父控件 */
@property (weak, nonatomic, readonly) UIScrollView *scrollView;

#pragma mark - 交给子类们去实现
/** 初始化 */
- (void)prepare NS_REQUIRES_SUPER;
/** 摆放子控件frame */
- (void)placeSubviews NS_REQUIRES_SUPER;
/** 当scrollView的contentOffset发生改变的时候调用 */
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的contentSize发生改变的时候调用 */
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的contentInset发生改变的时候调用 */
- (void)scrollViewContentInsetDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;
/** 当scrollView的拖拽状态发生改变的时候调用 */
- (void)scrollViewPanStateDidChange:(NSDictionary *)change NS_REQUIRES_SUPER;

#pragma mark - 其他
/** 拉拽的百分比(交给子类重写) */
@property (assign, nonatomic) CGFloat pullingPercent;
@end
