//
//  QBNavigatorStacks.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBViewModelService.h"
#import "QBNavigationController.h"

typedef NS_ENUM(NSUInteger, QBPageType) {
    QBPageTypeUnknow,
    QBPageTypeViewController,
    QBPageTypeNaviController,
    QBPageTypeTabbarController,
};

@interface QBNavigatorStacks : NSObject

- (instancetype)initWithService:(id<QBViewModelService>)service;

- (void)pushNavigationController:(QBNavigationController *)navigationController;
- (void)popNavigationController;
- (QBNavigationController *)topNavigationController;

@end
