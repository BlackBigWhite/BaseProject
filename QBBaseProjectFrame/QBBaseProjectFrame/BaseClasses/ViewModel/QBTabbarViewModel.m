//
//  QBTabbarViewModel.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBTabbarViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "NSObject+Property.h"
#import "QBRouter.h"
#import "QBNavigationController.h"

@interface QBTabbarViewModel ()


@end

@implementation QBTabbarViewModel
@synthesize service = _service;
@synthesize selfController = _selfController;
@synthesize naViewModels = _naViewModels;
@synthesize naViewControllers = _naViewControllers;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    QBTabbarViewModel *viewModel = [super allocWithZone:zone];
    
    @weakify(viewModel);
    RACSignal *initialParamsSignal = [viewModel rac_signalForSelector:@selector(initWithService:fetchParams:)];
    [[RACSignal merge:@[initialParamsSignal]]
     subscribeNext:^(id x) {
         @strongify(viewModel);
         [viewModel viewModelDidLoad];
     }];
    
    return viewModel;
}

- (instancetype)initWithService:(id<QBViewModelService>)service fetchParams:(NSDictionary *)params {
    self = [super init];
    if (!self) return nil;
    
    _service = service;
    
    if (params) {
        [self objAllocateValues:params];
    }
    
    return self;
}

- (void)viewModelDidLoad {}

@end
