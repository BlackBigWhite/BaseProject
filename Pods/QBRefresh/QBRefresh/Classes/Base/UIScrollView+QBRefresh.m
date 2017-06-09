//
//  UIScrollView+QBRefresh.m
//  刷新动画控件制作
//
//  Created by lizhihui on 16/7/22.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import "UIScrollView+QBRefresh.h"
#import <objc/runtime.h>
#import "QBRefreshComponent.h"

@implementation UIScrollView (QBRefresh)

- (void)setQb_header:(QBRefreshComponent *)qb_header {
    if (qb_header != self.qb_header) {
        [self insertSubview:qb_header atIndex:0];
        //!<KVO.
        [self willChangeValueForKey:@"qb_header"];
        objc_setAssociatedObject(self, @selector(qb_header),
                                 qb_header, OBJC_ASSOCIATION_RETAIN);
        [self didChangeValueForKey:@"qb_header"];
    }
}

- (QBRefreshComponent *)qb_header {
    return objc_getAssociatedObject(self, _cmd);
}

@end
