//
//  QBTabBarControllerProtocol.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/6.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QBTabBarViewModelProtocol;

@protocol QBTabBarControllerProtocol <NSObject>

@required

@property (nullable, nonatomic, strong, readonly) id<QBTabBarViewModelProtocol> viewModel;

/**
 初始化视图
 */
- (instancetype)initWithViewModel:(id<QBTabBarViewModelProtocol>)viewModel;

/**
 初始化后调用的方法
 */
- (void)bindViewModel;

@end

NS_ASSUME_NONNULL_END
