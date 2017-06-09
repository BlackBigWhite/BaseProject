//
//  QBTabBarControllerProtocol.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/6.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QBTableViewModelProtocol <NSObject>
@property (nullable, nonatomic, strong, readonly) id<QBTableViewModelProtocol> viewModel;
@property (nonatomic, strong) NSMutableArray *dataSource;    ///< table数据源
@property (nonatomic, assign) NSInteger rowHeight;
@property (nonatomic, assign) NSUInteger page;      ///< 翻页，页数
@property (nonatomic, strong) RACCommand *didSelectCommand; ///< 点击cell信号
@property (nonatomic, strong, readonly) RACCommand *requestDataCommand; ///<请求数据信号
@property (nonatomic, strong, readonly) RACCommand *requestLoadMoreDataCommand; ///<请求加载更多数据信号

/**
 请求数据，结果以信号形式返还
 */
- (RACSignal *)requestDataSignal;

/**
 加载更多数据，结果以信号形式返还
 */
- (RACSignal *)requestLoadMoreDataSignal;
@end

NS_ASSUME_NONNULL_END
