//
//  QBNavigatorStacks.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBNavigatorStacks.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "QBRouter.h"
#import "QBTabbarViewModel.h"
#import "QBViewController.h"
#import "QBTabBarViewController.h"

@interface QBNavigatorStacks ()

@property (nonatomic,strong) id<QBViewModelService> service;
@property (nonatomic,strong) NSMutableArray *navigationControllers;
@property (nonatomic, strong) QBTabBarViewController *currentTabBarViewController;

@end

@implementation QBNavigatorStacks


+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    QBNavigatorStacks *navigationControllerStack = [super allocWithZone:zone];
    
    @weakify(navigationControllerStack)
    [[navigationControllerStack
      rac_signalForSelector:@selector(initWithService:)]
    	subscribeNext:^(id x) {
            @strongify(navigationControllerStack)
            [navigationControllerStack registerNavigationHooks];
        }];
    
    return navigationControllerStack;
}

- (instancetype)initWithService:(id<QBViewModelService>)service {
    self = [super init];
    if (!self) return nil;
    
    _service = service;
    _navigationControllers = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)pushNavigationController:(QBNavigationController *)navigationController {
    if ([_navigationControllers containsObject:navigationController]) {
        return;
    }
    [_navigationControllers addObject:navigationController];
}

- (void)popNavigationController {
    if (_navigationControllers.count > 0) {
        [_navigationControllers removeLastObject];
    }
}

- (QBNavigationController *)topNavigationController {
    return _navigationControllers.lastObject;
}

- (UIWindow *)rootWindow {
    return [[UIApplication sharedApplication].windows firstObject];
}

- (void)registerNavigationHooks {
    
    @weakify(self);
    [[(NSObject *)self.service rac_signalForSelector:@selector(pushViewModel:animated:)]
     subscribeNext:^(RACTuple *tuple) {
         @strongify(self);
         id vc = [[QBRouter sharedRouter] viewControllerForViewModel:tuple.first];
         BOOL isAnimated = [tuple.second boolValue];
         if (![vc isKindOfClass:[QBNavigationController class]]) {
             [[self topNavigationController] pushViewController:vc animated:isAnimated];
         }
     }];
    
    [[(NSObject *)self.service rac_signalForSelector:@selector(popViewModelAnimated:)]
     subscribeNext:^(RACTuple *tuple) {
         @strongify(self);
         BOOL isAnimated = [tuple.first boolValue];
         [[self topNavigationController] popViewControllerAnimated:isAnimated];
     }];
    
    [[(NSObject *)self.service rac_signalForSelector:@selector(popToRootViewModelAnimated:)]
     subscribeNext:^(RACTuple *tuple) {
         @strongify(self)
         BOOL isAnimated = [tuple.first boolValue];
         [[self topNavigationController] popToRootViewControllerAnimated:isAnimated];
     }];
    
    [[(NSObject *)self.service rac_signalForSelector:@selector(resetRootViewModel:)]
     subscribeNext:^(RACTuple *tuple) {
         @strongify(self);
         [self.navigationControllers removeAllObjects];
         self.currentTabBarViewController = nil;
         
         id vm = tuple.first;
         id vc = [[QBRouter sharedRouter] viewControllerForViewModel:vm];
         QBPageType type = [self typeForViewController:vc];
         
         switch (type) {
             case QBPageTypeViewController:{
                 [self rootWindow].rootViewController = vc;
             }
                 break;
             case QBPageTypeNaviController:{
                 [self popNavigationController];
                 [self pushNavigationController:vc];
                 [self rootWindow].rootViewController = vc;
             }
                 break;
             case QBPageTypeTabbarController:{
                 self.currentTabBarViewController = vc;
                 @weakify(self);
                 [RACObserve(self.currentTabBarViewController, selectedViewController) subscribeNext:^(id  _Nullable x) {
                     @strongify(self);
                     [self popNavigationController];
                     [self pushNavigationController:x];
                 }];
                 [self rootWindow].rootViewController = vc;
             }
                 break;
             default:
                 break;
         }
     }];
    
    [[(NSObject *)self.service rac_signalForSelector:@selector(presentViewModel:animated:completion:)]
     subscribeNext:^(RACTuple *tuple) {
         @strongify(self);
         id vm = tuple.first;
         id vc = [[QBRouter sharedRouter] viewControllerForViewModel:vm];
         QBPageType type = [self typeForViewController:vc];
         BOOL isAnimated = [tuple.second boolValue];
         voidBlock block = [tuple.third copy];
         
         switch (type) {
             case QBPageTypeViewController:{
                 
                 QBNavigationViewModel *nvm = [[QBRouter sharedRouter] viewModelForProtocol:@"qbpr://QBNavigationViewModel" fetchParams:nil];
                 QBNavigationController *nvc = [[QBNavigationController alloc] initWithViewModel:nvm rootViewController:vc];
                 [[self topNavigationController] presentViewController:nvc animated:isAnimated completion:block];
                 [self pushNavigationController:nvc];
             }
                 break;
             case QBPageTypeNaviController:{
                 [[self topNavigationController] presentViewController:vc animated:isAnimated completion:block];
                 [self pushNavigationController:vc];
             }
                 break;
             default:
                 break;
         }
     }];
    
    [[(NSObject *)self.service rac_signalForSelector:@selector(dismissViewModelAnimated:completion:)]
     subscribeNext:^(RACTuple *tuple) {
         @strongify(self)
         BOOL isAnimated = [tuple.second boolValue];
         voidBlock block = [tuple.third copy];
         [[self topNavigationController] dismissViewControllerAnimated:isAnimated completion:block];
         [self popNavigationController];
     }];
    
    [[(NSObject *)self.service rac_signalForSelector:@selector(selectTabBarAtIndex:)]
     subscribeNext:^(RACTuple *tuple) {
         @strongify(self)
         NSInteger idx = [tuple.first integerValue];
         id vc = [self rootWindow].rootViewController;
         if ([vc isKindOfClass:[QBTabBarViewController class]]) {
             [vc setSelectedIndex:idx];
         }
     }];
    
    [[(NSObject *)self.service rac_signalForSelector:@selector(showAlertControllerWithTitle:message:cancelTitle:handler:otherTitle:handler:)]
     subscribeNext:^(RACTuple *tuple) {
         @strongify(self)
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:tuple.first message:tuple.second preferredStyle:UIAlertControllerStyleAlert];
         [alert addAction:[UIAlertAction actionWithTitle:tuple.third style:UIAlertActionStyleDefault handler:tuple.fourth]];
         [alert addAction:[UIAlertAction actionWithTitle:tuple.fifth style:UIAlertActionStyleDefault handler:tuple.last]];
         [[self topNavigationController] presentViewController:alert animated:YES completion:nil];
     }];
    
    [[(NSObject *)self.service rac_signalForSelector:@selector(showAlertControllerWithTitle:message:cancelTitle:handler:)]
     subscribeNext:^(RACTuple *tuple) {
         @strongify(self)
         UIAlertController *alert = [UIAlertController alertControllerWithTitle:tuple.first message:tuple.second preferredStyle:UIAlertControllerStyleAlert];
         [alert addAction:[UIAlertAction actionWithTitle:tuple.third style:UIAlertActionStyleDefault handler:tuple.fourth]];
         [[self topNavigationController] presentViewController:alert animated:YES completion:nil];
     }];
}

- (QBPageType)typeForViewController:(id)viewController {
    if ([viewController isKindOfClass:[QBTabBarViewController class]]) {
        return QBPageTypeTabbarController;
    } else if ([viewController isKindOfClass:[QBNavigationController class]]) {
        return QBPageTypeNaviController;
    } else if ([viewController isKindOfClass:[QBViewController class]]) {
        return QBPageTypeViewController;
    }
    return QBPageTypeUnknow;
}

@end
