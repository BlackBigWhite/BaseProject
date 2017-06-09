//
//  QBViewModelProtocol.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/6.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRouter.h"
#import "QBViewModelService.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QBNetworkState) {
    QBNetworkStateNormal,
    QBNetworkStateDisable,
};

@protocol QBViewModelProtocol <NSObject>

/**
 初始化方法
 */
- (instancetype)initWithService:(id<QBViewModelService>)service fetchParams:(NSDictionary *)params;

/**
 初始化后调用的方法
 */
- (void)viewModelDidLoad; // Step1


@property (nonatomic, strong) NSString *selfController;

/**
 @brief navigation bar title
 */
@property (nullable, nonatomic, copy) NSString *title;

/**
 service 用于页面跳转逻辑
 例 : [self.service pushViewModel:XXX animated:YES]
 */
@property (nonatomic,strong) id<QBViewModelService> service;
@property (nonatomic) QBRouterShowType showType;


/**
 请求数据信号
 */
@property (nonatomic, strong, readonly) RACCommand *requestCommand;
/**
 错误信号
 */
@property (nonatomic, strong, readonly) RACSubject *errors;

@property (nonatomic, assign) QBNetworkState networkState;


@required

@optional
- (RACSignal *)loadData;//!<加载数据.
@end

NS_ASSUME_NONNULL_END

