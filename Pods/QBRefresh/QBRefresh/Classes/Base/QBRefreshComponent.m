//
//  QBRefreshComponent.m
//  刷新动画控件制作
//
//  Created by lizhihui on 16/7/22.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import "QBRefreshComponent.h"

@interface QBRefreshComponent ()
@property (strong, nonatomic) UIPanGestureRecognizer *pan;
@end

@implementation QBRefreshComponent
#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 准备及初始化
        [self prepare];
        self.state = QBRefreshState_initial;
    }
    return self;
}

- (void)prepare {
    // 基本属性
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self placeSubviews];
}

- (void)placeSubviews{}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    // 如果不是UIScrollView，不做任何事情
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    // 旧的父控件移除监听
    [self removeObservers];
    
    if (newSuperview) { // 新的父控件
        // 设置宽度
        self.width = newSuperview.width;
        // 设置位置
        self.left = 0;
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 设置永远支持垂直弹簧效果
        _scrollView.alwaysBounceVertical = YES;
        // 记录UIScrollView最开始的contentInset
        _scrollViewOriginalInset = _scrollView.contentInset;
        // 添加监听
        [self addObservers];
    }
}

#pragma mark - KVO监听
- (void)addObservers {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:QBRefreshKeyPathContentOffset options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:QBRefreshKeyPathContentSize options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:QBRefreshKeyPathContentInset options:options context:nil];
    self.pan = self.scrollView.panGestureRecognizer;
    [self.pan addObserver:self forKeyPath:QBRefreshKeyPathPanState options:options context:nil];
}

- (void)removeObservers {
    [self.scrollView removeObserver:self forKeyPath:QBRefreshKeyPathContentOffset];
    [self.scrollView removeObserver:self forKeyPath:QBRefreshKeyPathContentSize];
    [self.scrollView removeObserver:self forKeyPath:QBRefreshKeyPathContentInset];
    [self.pan removeObserver:self forKeyPath:QBRefreshKeyPathPanState];
    self.pan = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 遇到这些情况就直接返回
    if (!self.userInteractionEnabled) return;
    
    // 这个就算看不见也需要处理
    if ([keyPath isEqualToString:QBRefreshKeyPathContentSize]) {
        [self scrollViewContentSizeDidChange:change];
    }
    
    // 看不见
    if (self.hidden) return;
    if ([keyPath isEqualToString:QBRefreshKeyPathContentOffset]) {
        [self scrollViewContentOffsetDidChange:change];
    } else if ([keyPath isEqualToString:QBRefreshKeyPathPanState]) {
        [self scrollViewPanStateDidChange:change];
    }
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change{}
- (void)scrollViewContentInsetDidChange:(NSDictionary *)change{}
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change{}
- (void)scrollViewPanStateDidChange:(NSDictionary *)change{}

- (void)setState:(QBRefreshState)state {
    _state = state;
    __weak typeof(self)weakSelf = self;
    // 加入主队列的目的是等setState:方法调用完毕、设置完文字后再去布局子控件
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf setNeedsLayout];
    });
}

#pragma mark 进入刷新状态
- (void)beginRefreshing {
    // 只要正在刷新，就完全显示
    if (self.window) {
        self.state = QBRefreshState_refreshing;
    } else {
        // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
        [self setNeedsDisplay];
    }
}

#pragma mark 结束刷新状态
- (void)endRefreshing {
    self.state = QBRefreshState_end;
}

#pragma mark 是否正在刷新
- (BOOL)isRefreshing {
    return self.state == QBRefreshState_refreshing;
}

#pragma mark - 内部方法
- (void)executeRefreshingCallback {
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.refreshingBlock) {
            weakSelf.refreshingBlock();
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
