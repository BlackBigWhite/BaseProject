//
//  QBViewController.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBViewController.h"
#import <QBCategories/UIColor+BGHexColor.h>

@interface QBViewController ()<UIGestureRecognizerDelegate>

@property (nullable, nonatomic, strong, readwrite) id<QBViewModelProtocol> viewModel;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;
@property (nonatomic, strong) UIView *snapshot;

@end

@implementation QBViewController
@synthesize viewModel = _viewModel;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    QBViewController *viewController = [super allocWithZone:zone];
    
    @weakify(viewController)
    [[viewController
      rac_signalForSelector:@selector(viewDidLoad)]
     subscribeNext:^(id x) {
         @strongify(viewController)
         [viewController bindViewModel];
     }];
    
    return viewController;
}

- (instancetype)initWithViewModel:(QBViewModel *)viewModel {
    self = [super init];
    if (self) {
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationBar = [QBNavBarCustom customNavBar];
    [self.view addSubview:self.navigationBar];
    [self navigationConfig:self.navigationBar];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    __weak typeof(self)weakSelf = self;
    [self.navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.equalTo(weakSelf.view);
        make.height.mas_equalTo(64);
    }];
}

- (void)navigationConfig:(QBNavBarCustom *)navigationBar {
#warning personality configuration according to the different project
    //!<标题样式.
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         [UIColor whiteColor], NSForegroundColorAttributeName,
                         [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:20.0], NSFontAttributeName, nil];
    [navigationBar setTitleTextAttributes:dic];
    //!<背景色及透明度.
    navigationBar.backgroundColor = [UIColor colorWithHexString:@"f94e4e"];
    //!<按钮样式.
    self.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)bindViewModel {
    // System title view
    RACChannelTo(self.navigationBar, title) = RACChannelTo(self.viewModel, title);
    
    @weakify(self)
    [self.viewModel.errors subscribeNext:^(NSError *error) {
        @strongify(self)
        
    }];
    
    [self subscribeNetworkStateSignal];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Being popped, take a snapshot
    if ([self isMovingFromParentViewController]) {
        self.snapshot = [self.navigationController.view snapshotViewAfterScreenUpdates:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#ifdef DEBUG
    
    [self debugMessage];
    
#endif
}

#pragma mark - subscribe network state signal

- (void)subscribeNetworkStateSignal {
    @weakify(self);
    [[RACObserve(self.viewModel, networkState) deliverOnMainThread] subscribeNext:^(NSNumber *value) {
        @strongify(self);
        [self checkNetworkState];
    }];
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil]
     subscribeNext:^(id x) {
         @strongify(self);
         [self checkNetworkState];
     }];
}

- (void)checkNetworkState {
    if (self.viewModel.networkState == QBNetworkStateNormal) {
        if ([self respondsToSelector:@selector(showNetworkNormal)]) {
            [self showNetworkNormal];
        }
    } else {
        if ([self respondsToSelector:@selector(showNetworkDisable)]) {
            [self showNetworkDisable];
        }
    }
}

- (void)showNetworkNormal {
    
}

- (void)showNetworkDisable {
    
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Debug message.

- (void)debugMessage {
    
    NSString        *classString = [NSString stringWithFormat:@" %@ ", [self class]];
    NSMutableString *flagString  = [NSMutableString string];
    
    for (int i = 0; i < classString.length; i++) {
        
        if (i == 0 || i == classString.length - 1) {
            
            [flagString appendString:@"+"];
            continue;
        }
        
        [flagString appendString:@"-"];
    }
    
    NSString *showSting = [NSString stringWithFormat:@"\n%@\n%@\n%@\n", flagString, classString, flagString];
    NSLog(@"%@", showSting);
}


@end
