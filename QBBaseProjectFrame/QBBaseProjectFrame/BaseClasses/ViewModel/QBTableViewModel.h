//
//  QBTableViewModel.h
//  QBBaseProjectFrame
//
//  Created by lizhihui on 2017/3/9.
//  Copyright © 2017年 qianbao. All rights reserved.
//

#import "QBViewModel.h"
#import "QBTableViewModelProtocol.h"

@interface QBTableViewModel : QBViewModel <QBTableViewModelProtocol>
@property (nonatomic, assign) BOOL isCanRefresh; //!<是否支持刷新.
@property (nonatomic, assign) BOOL isCanLoadMore;//!<是否可以加载更多.

@end
