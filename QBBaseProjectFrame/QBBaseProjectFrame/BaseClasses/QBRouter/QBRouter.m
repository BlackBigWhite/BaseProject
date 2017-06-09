//
//  QBRouter.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBRouter.h"
#import "QBNavigatorStacks.h"
#import "QBNavigationController.h"
#import "QBViewModelServiceImpl.h"
#import "QBViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "QBViewModel.h"
#import "QBTabbarViewModel.h"
#import "QBTabBarViewController.h"
#import "NSObject+Property.h"
#import "QBTabbarViewModel.h"
#import "QBWebViewModel.h"
#import "QBNavigationViewModel.h"

@interface QBRouter ()
@property (nonatomic,strong) NSMutableDictionary *pagesMapping;

@end

@implementation QBRouter

static NSMutableDictionary *dictionaryOfMappings;

+ (QBRouter *)sharedRouter {
    static QBRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[QBRouter alloc] init];
    });
    return router;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    _serviceImpl = [[QBViewModelServiceImpl alloc] init];
    _stacks = [[QBNavigatorStacks alloc] initWithService:_serviceImpl];
    _pagesMapping = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (BOOL)isProtocolValid:(NSString *)aProtocol {
    if (!aProtocol || aProtocol.length == 0) return NO;
    if (![aProtocol hasPrefix:QBPR_SCHEME_MARK]) return NO;
    return YES;
}

- (BOOL)isCallProtocolValid:(NSString *)aProtocol {
    if (!aProtocol || aProtocol.length == 0) return NO;
    if (![aProtocol hasPrefix:QBPR_CALL_MARK]) return NO;
    return YES;
}

#pragma mark - 对栈里对应vc的vm发消息
+ (void)performProtocol:(NSString *)aProtocol {
    [[QBRouter sharedRouter] performProtocol:aProtocol params:nil];
}

+ (void)performProtocol:(NSString *)aProtocol params:(NSDictionary *)params {
    [[QBRouter sharedRouter] performProtocol:aProtocol params:params];
}

- (void)performProtocol:(NSString *)aProtocol params:(NSDictionary *)params {
    
    if (![self isCallProtocolValid:aProtocol]) return;
    
    NSString *string = [aProtocol substringFromIndex:QBPR_CALL_MARK.length];
    NSArray *temp = [string componentsSeparatedByString:@"/"];
    if (!temp) return;
    
    NSString *vmString = temp.firstObject;
    NSString *vmMethodString = temp.lastObject;
    
    SEL sel = NSSelectorFromString(vmMethodString);
    
    NSArray *vcs = [_stacks.topNavigationController viewControllers];
    
    if (vcs.count - 2 > 0) {
        
        id<QBViewControlleProtocol> resultVc = vcs[vcs.count - 2];
        id<QBViewModelProtocol> resultVm = resultVc.viewModel;
        
        if ([NSStringFromClass([resultVm class]) isEqualToString:vmString]) {
            
            if ([resultVm respondsToSelector:sel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [resultVm performSelector:sel withObject:params];
#pragma clang diagnostic pop
            }
        }
    }
}

#pragma mark - open

+ (RACSignal *)openProtocol:(NSString *)aProtocol {
    return [QBRouter openProtocol:aProtocol fetchParams:nil];
}

+ (RACSignal *)openProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params {
    return [QBRouter openProtocol:aProtocol fetchParams:params isAnimated:YES];
}

+ (RACSignal *)openProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params isAnimated:(BOOL)isAnimated {
    return [[QBRouter sharedRouter] openProtocol:aProtocol fetchParams:params isAnimated:isAnimated];
}

- (RACSignal *)openProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params isAnimated:(BOOL)isAnimated {
    
    if (![self isProtocolValid:aProtocol]) return nil;
    
    NSArray *temp = nil;
    NSString *vmString = [aProtocol substringFromIndex:QBPR_SCHEME_MARK.length];
    temp = [vmString componentsSeparatedByString:@"/"];
    if (!temp) return [RACSignal empty];
    
    
    QBViewModel *vm = [self viewModelForName:temp.firstObject fetchParams:params];
    if (vm) {
        vm.showType = QBRouterShowTypePush;
        vm.selfController = temp.lastObject;
        [_serviceImpl pushViewModel:vm animated:isAnimated];
    }
    return [RACSignal empty];
}
+ (RACSignal *)openUrlString:(NSString *)urlString {
    return [[QBRouter sharedRouter] openUrlString:urlString];
}

- (RACSignal *)openUrlString:(NSString *)urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:nil completionHandler:nil];
        }else
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] ];
    }
    return [RACSignal empty];
}


#pragma mark - present

// present
+ (RACSignal *)presentProtocol:(NSString *)aProtocol {
    return [QBRouter presentProtocol:aProtocol fetchParams:nil];
}

+ (RACSignal *)presentProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params {
    return [QBRouter presentProtocol:aProtocol fetchParams:params fetchVoidBlock:nil];
}

+ (RACSignal *)presentProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params fetchVoidBlock:(voidBlock)block  {
    return [QBRouter presentProtocol:aProtocol fetchParams:params fetchVoidBlock:block isAnimated:YES];
}

+ (RACSignal *)presentProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params fetchVoidBlock:(voidBlock)block isAnimated:(BOOL)isAnimated {
    return [[QBRouter sharedRouter] presentProtocol:aProtocol fetchParams:params fetchVoidBlock:block isAnimated:isAnimated];
}

- (RACSignal *)presentProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params fetchVoidBlock:(voidBlock)block isAnimated:(BOOL)isAnimated {
    
    if (![self isProtocolValid:aProtocol]) return nil;
    
    NSArray *temp = nil;
    NSString *vmString = [aProtocol substringFromIndex:QBPR_SCHEME_MARK.length];
    temp = [vmString componentsSeparatedByString:@"/"];
    if (!temp) return [RACSignal empty];
    
    
    QBViewModel *vm = [self viewModelForName:temp.firstObject fetchParams:params];
    if (vm) {
        vm.showType = QBRouterShowTypePresent;
        vm.selfController = temp.lastObject;
        [_serviceImpl presentViewModel:vm animated:isAnimated completion:block];
    }
    return [RACSignal empty];
}

#pragma mark - reset
+ (void)resetProtocol:(NSString *)aProtocol {
    [QBRouter resetProtocol:aProtocol fetchParams:nil];
}

+ (void)resetProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params {
    [[QBRouter sharedRouter] resetProtocol:aProtocol fetchParams:params];
}

- (void)resetProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params {
    if (![self isProtocolValid:aProtocol]) return;
    
    NSArray *temp = nil;
    NSString *vmString = [aProtocol substringFromIndex:QBPR_SCHEME_MARK.length];
    temp = [vmString componentsSeparatedByString:@"/"];
    if (!temp) return;
    
    
    QBViewModel *vm = [self viewModelForName:temp.firstObject fetchParams:params];
    if (vm) {
        vm.selfController = temp.lastObject;
        [_serviceImpl resetRootViewModel:vm];
    }
}

#pragma mark - tabBar切换
+ (void)selectTabBarAtIndex:(NSInteger)idx {
    [[QBRouter sharedRouter] selectTabBarAtIndex:idx];
}

- (void)selectTabBarAtIndex:(NSInteger)idx {
    [self.serviceImpl popToRootViewModelAnimated:NO];
    [self.serviceImpl selectTabBarAtIndex:idx];
}

#pragma mark - close
+ (void)popAnimationed:(BOOL)animated {
    [[QBRouter sharedRouter].serviceImpl popViewModelAnimated:animated];
}

+ (void)popToIndex:(NSInteger)index {
    [[QBRouter sharedRouter] popToIndex:index];
}

+ (void)popToProtocol:(NSString *)aProtocol {
    [[QBRouter sharedRouter] popToProtocol:aProtocol];
}

+ (void)popToRootAnimationed:(BOOL)animated {
    [[QBRouter sharedRouter].serviceImpl popToRootViewModelAnimated:animated];
}

+ (void)dismissAnimated:(BOOL)isAnimated completion:(voidBlock)completion {
    [[QBRouter sharedRouter].serviceImpl dismissViewModelAnimated:isAnimated completion:completion];
}

- (void)popToIndex:(NSInteger)index {
    NSInteger count = _stacks.topNavigationController.viewControllers.count;
    if (count < index && index < 100) return;
    
    if (index > 100 || index == count - 1) {
        [_stacks.topNavigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (index != count - 1) {
        NSArray *oldvcs = [[_stacks.topNavigationController viewControllers] mutableCopy];
        
        NSMutableArray *newvcs = [NSMutableArray array];
        [oldvcs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            [newvcs addObject:obj];
            if (idx == index) *stop = YES;
            
        }];
        
        _stacks.topNavigationController.viewControllers = newvcs;
        return;
    }
}

- (void)popToProtocol:(NSString *)aProtocol {
    if (![self isProtocolValid:aProtocol]) return;
    
    NSString *vmString = [aProtocol substringFromIndex:QBPR_SCHEME_MARK.length];
    NSArray *temp = [vmString componentsSeparatedByString:@"/"];
    if (!temp) return;
    
    NSString *vc = temp.lastObject;
    NSArray *vcs = _stacks.topNavigationController.viewControllers;
    Class class = NSClassFromString(vc);
    
    NSMutableArray *newvcs = [NSMutableArray array];
    [vcs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [newvcs addObject:obj];
        if ([obj isKindOfClass:class]) {
            *stop = YES;
        }
    }];
    
    _stacks.topNavigationController.viewControllers = newvcs;
}



- (id)viewModelForProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params {
    if (![self isProtocolValid:aProtocol]) return nil;
    
    NSString *vm = [aProtocol substringFromIndex:QBPR_SCHEME_MARK.length];
    Class class = NSClassFromString(vm);
    
    return [[class alloc] initWithService:_serviceImpl fetchParams:params];
}


- (id)viewControllerForProtocol:(NSString *)aProtocol fetchParams:(NSDictionary *)params {
    if (![self isProtocolValid:aProtocol]) return [self defaultViewController];
    
    id viewModel = [self viewModelForProtocol:aProtocol fetchParams:params];
    if (!viewModel) return [self defaultViewController];
    
    return [self viewControllerForViewModel:viewModel];
}


#pragma mark - controller

- (id)viewControllerForViewModel:(QBViewModel *)viewModel {
    if (!viewModel) return [self defaultViewController];
    
    id controller = [[NSClassFromString(viewModel.selfController) alloc] initWithViewModel:viewModel];
    if (!controller) return [self defaultViewController];
    
    return controller;
}

#pragma mark - viewmodel
- (id)viewModelForName:(NSString *)vmName fetchParams:(NSDictionary *)params {
    
    Class class = NSClassFromString(vmName);
    
    return [[class alloc] initWithService:_serviceImpl fetchParams:params];
    
}

#pragma mark - NavigationController
- (QBNavigationController *)navigationControllerForViewModel:(NSString *)viewModel controller:(NSString *)controller {
    
    QBViewModel *vm = [self viewModelForName:viewModel fetchParams:nil];
    if (!vm) return [self defaultNavigationController];
    
    vm.selfController = controller;
    QBViewController *vc = [self viewControllerForViewModel:vm];
    if (!vc) return [self defaultNavigationController];
    
    QBNavigationViewModel *nvm = [self viewModelForName:@"QBNavigationViewModel" fetchParams:nil];
    
    QBNavigationController *nvc = [[QBNavigationController alloc] initWithViewModel:nvm rootViewController:vc];
    
    return nvc;
}



#pragma mark - default
- (QBNavigationController *)defaultNavigationController {
    QBNavigationViewModel *nvm = [self viewModelForName:@"QBNavigationViewModel" fetchParams:nil];
    
    QBNavigationController *nvc = [[QBNavigationController alloc] initWithViewModel:nvm rootViewController:[self defaultViewController]];
    
    return nvc;
}

- (QBViewController *)defaultViewController {
    
    QBViewModel *vm = [self viewModelForName:@"QBViewModel" fetchParams:nil];
    vm.selfController = @"QBViewController";
    return [self viewControllerForViewModel:vm];
}

+ (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler
                          otherTitle:(nullable NSString *)otherTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))otherHandler {
    [[QBRouter sharedRouter] showAlertControllerWithTitle:title message:message cancelTitle:cancelTitle handler:cancelHandler otherTitle:otherTitle handler:otherHandler];
}

+ (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler {
    [[QBRouter sharedRouter] showAlertControllerWithTitle:title message:message cancelTitle:cancelTitle handler:cancelHandler];
}

- (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler
                          otherTitle:(nullable NSString *)otherTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))otherHandler {
    [self.serviceImpl showAlertControllerWithTitle:title message:message cancelTitle:cancelTitle handler:cancelHandler otherTitle:otherTitle handler:otherHandler];
}

- (void)showAlertControllerWithTitle:(nullable NSString *)title
                             message:(nullable NSString *)message
                         cancelTitle:(nullable NSString *)cancelTitle
                             handler:(void (^)(UIAlertAction * _Nonnull action))cancelHandler {
    [self.serviceImpl showAlertControllerWithTitle:title message:message cancelTitle:cancelTitle handler:cancelHandler];
}

@end
