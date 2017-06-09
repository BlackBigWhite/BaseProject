//
//  QBRouter.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "QBNavigatorStacks.h"
@class QBViewModelServiceImpl;
@class QBViewController;
@class QBNavigationController;
@class QBViewModel;

/**
 QBPR_SCHEME_MARK : 协议标志,所有的跳转、请求协议必须有该协议头
 例如： @"qbpr://viewModel/viewController";
 */

static NSString * const QBPR_SCHEME_MARK = @"qbpr://";

/**
 QBPR_SCHEME_MARK : 回调标志,方法传值、属性赋值
 例如： @"qbpr://viewModel/method";
 */
static NSString * const QBPR_CALL_MARK = @"qbcall://";

typedef void (^ QBRouterActionBlock)(id params);
typedef void (^ voidBlock)();


typedef NS_ENUM(NSInteger,QBRouterType) {
    QBRouterTypeUnknow = 0,
    QBRouterTypePage = 1,
    QBRouterTypeWebView = 2,
    QBRouterTypeTabbar = 3,
};

typedef NS_ENUM(NSInteger,QBRouterShowType) {
    QBRouterShowTypePush = 0,
    QBRouterShowTypePresent = 1,
    QBRouterShowTypeReset = 2,
};

@interface QBRouter : NSObject

+ (QBRouter *)sharedRouter;

@property (nonatomic,strong) QBNavigatorStacks *stacks;
@property (nonatomic,strong) QBViewModelServiceImpl *serviceImpl;

///--------------
/// 用于基本页面跳转
///--------------


/**
 push跳转
 
 @param aProtocol @"qbpr://viewModel/viewController"
 @return 待注册信号
 */
+ (RACSignal *)openProtocol:(NSString *)aProtocol;


/**
 @param params key必须是viewModel中定义属性名
 */
+ (RACSignal *)openProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params;
+ (RACSignal *)openProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params isAnimated:(BOOL)isAnimated;


/**
 present跳转
 
 @param aProtocol @"qbpr://viewModel/viewController"
 @return 待注册信号
 */
+ (RACSignal *)presentProtocol:(NSString *)aProtocol;

/**
 @param params key必须是viewModel中定义属性名
 */
+ (RACSignal *)presentProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params;
+ (RACSignal *)presentProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params fetchVoidBlock:(voidBlock)block isAnimated:(BOOL)isAnimated;


/**
 reset 设置rootWindow
 
 @param aProtocol @"qbpr://TabBarviewModel/TabBarviewController"
 */
+ (void)resetProtocol:(NSString *)aProtocol;

/**
 @param params key必须是viewModel中定义属性名
 */
+ (void)resetProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params;


/**
 pop跳转，返回上一层
 */
+ (void)popAnimationed:(BOOL)animated;

/**
 pop跳转，返回到指定控制器
 
 @param index 控制器在栈中的下标
 */
+ (void)popToIndex:(NSInteger)index;

/**
 pop跳转，返回到指定控制器
 
 @param aProtocol @"qbpr://viewModel/viewController"
 */
+ (void)popToProtocol:(NSString *)aProtocol;

/**
 pop跳转，返回到根控制器
 */
+ (void)popToRootAnimationed:(BOOL)animated;

/**
 dismiss跳转
 */
+ (void)dismissAnimated:(BOOL)isAnimated completion:(voidBlock)completion;

///-----------
/// 类具体的方法
///-----------


/**
 创建对应ViewController
 
 @param viewModel vm实例
 @return viewController
 */
- (id)viewControllerForViewModel:(QBViewModel *)viewModel;

/**
 创建viewModel
 
 @param aProtocol @"qbpr://viewModel"
 @param params key必须是viewModel中定义属性名
 @return viewModel实例
 */
- (id)viewModelForProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params;


/**
 创建viewController
 
 @param aProtocol @"qbpr://viewModel/viewController"
 @param params key必须是viewModel中定义属性名
 @return viewController实例
 */
- (id)viewControllerForProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params;


/**
 创建导航控制器
 
 @param viewModel rootVc对应vm
 @param controller rootvc
 */
- (QBNavigationController *)navigationControllerForViewModel:(NSString *)viewModel controller:(NSString *)controller;


/**
 tabBar切换
 */
+ (void)selectTabBarAtIndex:(NSInteger)idx;


/**
 回调栈中viewModel中的函数
 
 @param aProtocol 例如： @"qbcall://viewModel/method";
 */
+ (void)performProtocol:(NSString *)aProtocol;


/**
 回调栈中viewModel中的函数
 
 @param aProtocol 例如： @"qbcall://viewModel/method";
 @param params  key必须是viewModel中定义属性名
 */
+ (void)performProtocol:(NSString *)aProtocol params:(NSDictionary *)params;



/**
 创建默认导航控制器
 */
- (QBNavigationController *)defaultNavigationController;


/**
 创建默认viewController
 */
- (QBViewController *)defaultViewController;

+ (RACSignal *)openUrlString:(NSString *)urlString;

/**
 alertController
 */
+ (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler
                          otherTitle:(nullable NSString *)otherTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))otherHandler;

+ (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler;
@end
