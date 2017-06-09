//
//  QBWebViewModel.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBViewModel.h"

@interface QBWebViewModel : QBViewModel

@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *htmlPath;

/**
 是否显示加载进度 (默认YES)
 */
@property (nonatomic, assign) BOOL shouldShowProgress;

/**
 是否使用WebPage的title作为导航栏title（默认YES）
 */
@property (nonatomic, assign) BOOL isUseWebPageTitle;

/**
 是否支持滚动（默认YES）
 */
@property (nonatomic, assign) BOOL scrollEnabled;

/**
 导航栏左侧按钮
 */
@property (nonatomic, strong) NSArray *leftNavItems;

/**
 表示加载成功过,不表示当前是否加载成功
 */
@property (nonatomic, assign) BOOL successLoad;


@end
