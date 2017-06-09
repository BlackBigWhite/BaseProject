//
//  QBTabBarViewModelProtocol.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/6.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBViewModelService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QBTabBarViewModelProtocol <NSObject>

@required

@property (nonatomic, strong) id<QBViewModelService> service;

@property (nonatomic, strong) NSMutableArray *naViewModels;
@property (nonatomic, strong) NSMutableArray *naViewControllers;
@property (nonatomic, strong) NSString *selfController;


/**
 初始化方法
 */
- (instancetype)initWithService:(id<QBViewModelService>)service fetchParams:(NSDictionary *)params;

/**
 初始化后调用的方法
 */
- (void)viewModelDidLoad;


@end
NS_ASSUME_NONNULL_END
