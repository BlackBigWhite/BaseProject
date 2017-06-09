//
//  QBViewModelServiceImpl.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBViewModelServiceImpl.h"

@implementation QBViewModelServiceImpl

- (void)pushViewModel:(QBViewModel *)viewModel animated:(BOOL)animated {}

- (void)popViewModelAnimated:(BOOL)animated {}

- (void)popToRootViewModelAnimated:(BOOL)animated {}

- (void)presentViewModel:(QBViewModel *)viewModel animated:(BOOL)animated completion:(voidBlock)completion {}

- (void)dismissViewModelAnimated:(BOOL)animated completion:(voidBlock)completion {}

- (void)resetRootViewModel:(QBViewModel *)viewModel {}

- (void)selectTabBarAtIndex:(NSInteger)idx {}

- (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler
                          otherTitle:(nullable NSString *)otherTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))otherHandler {}
- (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler {}
@end
