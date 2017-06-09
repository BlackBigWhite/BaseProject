//
//  QBToolbarCustom.m
//  导航控制器
//
//  Created by lizhihui on 2017/3/4.
//  Copyright © 2017年 lizhihui. All rights reserved.
//

#import "QBToolbarCustom.h"

@implementation QBToolbarCustom

- (id)init {
    if ((self = [super init])) {
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clearsContextBeforeDrawing = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // do nothing
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
