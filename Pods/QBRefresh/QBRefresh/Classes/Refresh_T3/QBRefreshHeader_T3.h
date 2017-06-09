//
//  QBAnimationRefreshHeader.h
//  刷新动画控件制作
//
//  Created by lizhihui on 16/7/22.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import "QBRefreshComponent.h"

@interface QBRefreshHeader_T3 : QBRefreshComponent
+ (instancetype)headerWithRefreshingBlock:(QBRefreshingBlock)refreshingBlock;
/** 进入刷新状态 */
- (void)beginRefreshing;
/** 结束刷新状态并显示"刷新成功"字样 */
- (void)endRefreshing;
/** 是否正在刷新 */
- (BOOL)isRefreshing;
@end
