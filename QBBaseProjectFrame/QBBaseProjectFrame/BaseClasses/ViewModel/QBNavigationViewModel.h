//
//  QBNavigationViewModel.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/9.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBViewModelService.h"

@interface QBNavigationViewModel : NSObject

@property (nonatomic, strong) id<QBViewModelService> service;

@property (nonatomic, strong) NSMutableArray *viewModels;
@property (nonatomic, strong) NSString *selfNavController;

/**
 初始化方法
 */
- (instancetype)initWithService:(id<QBViewModelService>)service fetchParams:(NSDictionary *)params;

/**
 初始化后调用的方法
 */
- (void)viewModelDidLoad;

@end
