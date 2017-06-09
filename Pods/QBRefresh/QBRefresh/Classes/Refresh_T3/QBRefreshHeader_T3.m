//
//  QBAnimationRefreshHeader.m
//  刷新动画控件制作
//
//  Created by lizhihui on 16/7/22.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import "QBRefreshHeader_T3.h"

#define COLOR_RGB(r,g,b) [UIColor colorWithRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:1]

@interface QBRefreshHeader_T3 () {
    __unsafe_unretained UIImageView *_gifView;
}
/** 所有状态对应的动画图片 */
@property (strong, nonatomic) NSMutableDictionary *stateImages;
/** 所有状态对应的动画时间 */
@property (strong, nonatomic) NSMutableDictionary *stateDurations;
@end

@implementation QBRefreshHeader_T3
#pragma mark - 构造方法QBRefreshHeader
+ (instancetype)headerWithRefreshingBlock:(QBRefreshingBlock)refreshingBlock {
    QBRefreshHeader_T3 *cmp = [[self alloc] init];
    cmp.refreshingBlock = refreshingBlock;
    return cmp;
}

#pragma mark - 覆盖父类的方法
- (void)prepare {
    [super prepare];
    //设置高度
    self.height = QBRefreshHeaderHeight;
    self.top = -self.height;
    
    NSMutableArray *gifArr = [NSMutableArray arrayWithCapacity:4];
    for (int i = 1; i <= 15; i ++) {
        UIImage *img = [self getImageByName:[NSString stringWithFormat:@"refresh%zd", i]];
        if (img) {
            [gifArr addObject:img];
        }
    }
    UIImage *img_initial = [self getImageByName:@"refresh15"];
    
    [self setImages:@[img_initial] duration:10 forState:QBRefreshState_initial];
    [self setImages:@[img_initial] duration:10 forState:QBRefreshState_pulling];
    [self setImages:@[img_initial] duration:10 forState:QBRefreshState_will_refreshing];
    [self setImages:gifArr duration:10 forState:QBRefreshState_refreshing];

}

- (void)placeSubviews {
    [super placeSubviews];
    // 设置y值(当自己的高度发生改变了，肯定要重新调整Y值，所以放到placeSubviews方法中设置y值)
    if (self.gifView.constraints.count) return;
    self.gifView.frame = CGRectMake(0, 20, self.width, self.height-20);
    self.gifView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    //!<控制最大偏移量.
    if (self.scrollView.contentOffset.y < -QBRefreshMaxOffset && QBRefreshMaxOffset > 0) {
        self.scrollView.contentOffset = CGPointMake(0, -QBRefreshMaxOffset);
    }
    
    if (self.state == QBRefreshState_refreshing) return;
    // 跳转到下一个控制器时，contentInset可能会变
    _scrollViewOriginalInset = self.scrollView.contentInset;
    // 当前的contentOffset
    CGFloat offsetY = self.scrollView.contentOffset.y;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = - self.scrollViewOriginalInset.top;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (offsetY > happenOffsetY) return;
    
    // 普通 和 即将刷新 的临界点
    CGFloat normalpullingOffsetY = happenOffsetY - self.height;
    CGFloat pullingPercent = (happenOffsetY - offsetY) / self.height;
    self.pullingPercent = pullingPercent;

    //!<只有在拖动停止的时候才能设置为刷新状态,在拖动过程中只能确定是否可以刷新,即只能设置为QBRefreshState_will_refreshing.
    if (self.scrollView.isDragging) { // 如果正在拖拽
        if (fabs(offsetY) >= fabs(normalpullingOffsetY)) {//!<即将刷新.
            // 转为即将刷新状态
            self.state = QBRefreshState_will_refreshing;
        } else if (offsetY > normalpullingOffsetY) {
            self.state = QBRefreshState_pulling;
        }
    } else {
        if (self.state == QBRefreshState_will_refreshing) {
            self.state = QBRefreshState_refreshing;
        }else {
            self.state = QBRefreshState_initial;
        }
    }
}

- (void)setState:(QBRefreshState)state {
    QBRefreshCheckState
    //初始状态
    if (state == QBRefreshState_initial) {
        if (oldState = QBRefreshState_initial) return;
        if (oldState != QBRefreshState_refreshing) return;
        [self recover];
        [self clearGif];
    }
    //!<即将刷新.
    if (state == QBRefreshState_will_refreshing) {
        if (oldState == QBRefreshState_will_refreshing)return;
        [self gifAnmationViewWithImgs:self.stateImages[@(QBRefreshState_will_refreshing)]];
    }
    //!<正在刷新.
    if (state == QBRefreshState_refreshing) {
        if (oldState == QBRefreshState_refreshing)return;
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:0.25 animations:^{
            weakSelf.scrollView.contentInset = UIEdgeInsetsMake(QBRefreshHeaderHeight, 0, 0, 0);
            weakSelf.scrollView.bounces = NO;
        } completion:^(BOOL finished) {
            if (finished) {
                weakSelf.scrollView.bounces = YES;
                [weakSelf scrollToTop];
            }

        }];
        [self executeRefreshingCallback];
        [self gifAnmationViewWithImgs:self.stateImages[@(QBRefreshState_refreshing)]];
    }

    //!<拖动中.
    if (state == QBRefreshState_pulling) {
        [self clearGif];
        NSArray *images = self.stateImages[@(QBRefreshState_pulling)];
        NSUInteger index =  images.count * self.pullingPercent;
        if (index >= images.count) {
            self.gifView.image = images.lastObject;
        }else {
            self.gifView.image = images[index];
        }

    }
    //!<刷新结束.
    if (state == QBRefreshState_end) {
        [self clearGif];
        self.state = QBRefreshState_initial;
        double delayInSeconds = 0.25;
        __weak typeof(self)weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [weakSelf recover];
        });

    }
}

#pragma mark - 重置并恢复scrollview的contentInset
- (void)recover {
    __weak typeof(self)weakSelf = self;
    self.scrollView.userInteractionEnabled = NO;
    [UIView animateWithDuration:QBRefreshSlowAnimationDuration animations:^{
        UIEdgeInsets inset = weakSelf.scrollView.contentInset;
        inset.top = 0;
        weakSelf.scrollView.contentInset = inset;
    } completion:^(BOOL finished) {
        if (finished) {
            weakSelf.scrollView.userInteractionEnabled = YES;
            [weakSelf scrollToTop];
            weakSelf.pullingPercent = 0.0;
            weakSelf.state = QBRefreshState_initial;
        }
    }];

}

#pragma mark - scrollView scroll to top
- (void)scrollToTop {
    __weak typeof(self)weakSelf = self;
    CGPoint offect = self.scrollView.contentOffset;
    offect.y = - self.scrollView.contentInset.top;
    weakSelf.scrollView.userInteractionEnabled = NO;
    weakSelf.scrollView.bounces = NO;
    [UIView animateWithDuration:QBRefreshSlowAnimationDuration animations:^{
        [weakSelf.scrollView setContentOffset:offect];
    } completion:^(BOOL finished) {
        if (finished) {
            weakSelf.scrollView.bounces = YES;
            weakSelf.scrollView.userInteractionEnabled = YES;
        }
    }];
}

- (void)setImages:(NSArray *)images duration:(NSTimeInterval)duration forState:(QBRefreshState)state {
    if (images == nil) return;
    self.stateImages[@(state)] = images;
    self.stateDurations[@(state)] = @(duration);
}

- (void)gifAnmationViewWithImgs:(NSArray *)imgs {
    if (imgs.count > 0) {
        self.gifView.animationImages = imgs;
        self.gifView.animationDuration = imgs.count * 0.05;
        [self.gifView startAnimating];
    }
}

- (void)clearGif {
    self.gifView.image = nil;
    self.gifView.animationImages = nil;
}

#pragma mark - 实现父类的方法

- (void)endRefreshing {
    if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [super endRefreshing];
        });
    } else {
        [super endRefreshing];
    }
}

#pragma mark - 懒加载
- (UIImageView *)gifView {
    if (!_gifView) {
        UIImageView *gifView = [[UIImageView alloc] init];
        [self addSubview:_gifView = gifView];
    }
    return _gifView;
}

- (NSMutableDictionary *)stateImages {
    if (!_stateImages) {
        self.stateImages = [NSMutableDictionary dictionary];
    }
    return _stateImages;
}

- (NSMutableDictionary *)stateDurations {
    if (!_stateDurations) {
        self.stateDurations = [NSMutableDictionary dictionary];
    }
    return _stateDurations;
}

- (UIImage *)getImageByName:(NSString *)imageName{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"Resources_T3" ofType:@"bundle"];
    NSBundle *resourcesBundle = [NSBundle bundleWithPath:path];
    return [UIImage imageNamed:imageName inBundle:resourcesBundle compatibleWithTraitCollection:nil];
}

@end
