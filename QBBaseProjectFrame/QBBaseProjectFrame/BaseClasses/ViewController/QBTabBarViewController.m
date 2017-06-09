//
//  QBTabBarViewController.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBTabBarViewController.h"
#import "QBTabbarViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "QBRouter.h"
#import <QBCategories/UIColor+BGHexColor.h>

@interface QBTabBarViewController ()
@property (nullable, nonatomic, strong, readwrite) QBTabbarViewModel<QBTabBarViewModelProtocol> *viewModel;
@end

@implementation QBTabBarViewController

- (void)customConfigWithConfigName:(NSString *)configFileName {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:configFileName ofType:@"plist"];
    NSDictionary *style = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSArray *controllersArr = style[@"viewcontrollers"];
    NSMutableArray *controllers = [NSMutableArray array];
    for (NSDictionary *obj in controllersArr) {
        QBNavigationController *rootVc = [[QBRouter sharedRouter] navigationControllerForViewModel:obj[@"viewModel"] controller:obj[@"controller"]];
        rootVc.tabBarItem.image = [UIImage imageNamed:obj[@"image"]];
        rootVc.tabBarItem.selectedImage = [UIImage imageNamed:obj[@"selectedImage"]];
        rootVc.tabBarItem.title = obj[@"title"];
        [controllers addObject:rootVc];

    }
    self.viewControllers = controllers;
    
    NSDictionary *tabBarStyle = style[@"tabbar"];
    [self.tabBar setTintColor:[UIColor colorWithHexString:tabBarStyle[@"tintColor"]]];
    [self.tabBar setBarTintColor:[UIColor colorWithHexString:tabBarStyle[@"barTintColor"]]];
}

- (instancetype)initWithViewModel:(id<QBTabBarViewModelProtocol>)viewModel {
    self = [super init];
    if (!self) return nil;
    self.viewModel = viewModel;
    [self bindViewModel];
    return self;
}

- (void)bindViewModel {
    @weakify(self);
    [RACObserve(self.viewModel, configFileName) subscribeNext:^(NSString *x) {
        @strongify(self);
        [self customConfigWithConfigName:x];
    }];
}


@end
