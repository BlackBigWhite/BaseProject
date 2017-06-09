//
//  QBNavigationController.m
//  QBBaseProjectFrame
//
//  Created by Qiaokai on 2017/3/7.
//  Copyright © 2017年 qianbao. All rights reserved.
//

#import "QBNavigationController.h"
#import "QBViewController.h"

@interface QBNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@property (nullable, nonatomic, strong, readwrite) id viewModel;

@end

@implementation QBNavigationController

#pragma mark - life cycle


- (instancetype)initWithViewModel:(QBNavigationViewModel *)viewModel rootViewController:(id)root {
    self = [super initWithRootViewController:root];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationBar.hidden = YES;
    //!<替换系统左滑手势.
    id target = self.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    self.interactivePopGestureRecognizer.enabled = NO;
    //!<导航代理.
    self.delegate = self;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationBar.hidden = YES;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

#pragma mark - UIGestureRecognizerDelegate method

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //!<触发左滑基本逻辑:根视图控制器无效,其他有效.
    if (self.childViewControllers.count == 1) {
        // 表示用户在根控制器界面，就不需要触发滑动手势，
        return NO;
    }
    if ([self.topViewController isKindOfClass:[QBViewController class]]) {
        return NO;
    }
    return YES;
}

#pragma mark - UINavigationControllerDelegate method

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count > 0) { // 如果push进来的不是第一个控制器
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (navigationController.viewControllers.firstObject != viewController) {
        UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
        QBViewController *controller = (QBViewController *)viewController;
        if ([viewController isKindOfClass:[QBViewController class]] && controller.navigationBar.leftBarButtonItems.count == 0) {
            controller.navigationBar.leftBarButtonItem = leftItem;
        }
        if ([viewController isMemberOfClass:[UIViewController class]] && viewController.navigationItem.leftBarButtonItems.count == 0) {
            controller.navigationItem.leftBarButtonItem = leftItem;
        }
    }
}

- (void)back:(UIBarButtonItem *)item {
    [SVProgressHUD dismiss];
    [self popViewControllerAnimated:YES];
}

@end
