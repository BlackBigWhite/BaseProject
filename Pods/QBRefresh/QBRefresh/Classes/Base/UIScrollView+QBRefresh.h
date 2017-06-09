//
//  UIScrollView+QBRefresh.h
//  刷新动画控件制作
//
//  Created by lizhihui on 16/7/22.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QBRefreshComponent;

@interface UIScrollView (QBRefresh)
@property (strong, nonatomic) QBRefreshComponent *qb_header;
@end
