//
//  QBViewModelService.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QBViewModel;

typedef void (^ voidBlock)();

@protocol QBViewModelService <NSObject>


/**
 跳转一个控制器
 */
- (void)pushViewModel:(QBViewModel *)viewModel animated:(BOOL)animated;

/**
 跳转回一个控制器
 */
- (void)popViewModelAnimated:(BOOL)animated;

/**
 跳转至根视图
 */
- (void)popToRootViewModelAnimated:(BOOL)animated;

/**
 呈现一个视图
 */
- (void)presentViewModel:(QBViewModel *)viewModel animated:(BOOL)animated completion:(voidBlock)completion;

/**
 取消一个视图
 */
- (void)dismissViewModelAnimated:(BOOL)animated completion:(voidBlock)completion;

/**
 重新设置一个根视图
 */
- (void)resetRootViewModel:(QBViewModel *)viewModel;


/**
 tabBar切换
 */
- (void)selectTabBarAtIndex:(NSInteger)idx;

- (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler
                          otherTitle:(nullable NSString *)otherTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))otherHandler;

- (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler;


@end
