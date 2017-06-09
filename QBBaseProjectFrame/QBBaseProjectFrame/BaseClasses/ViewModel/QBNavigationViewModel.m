//
//  QBNavigationViewModel.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/9.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBNavigationViewModel.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "NSObject+Property.h"


@implementation QBNavigationViewModel

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    QBNavigationViewModel *viewModel = [super allocWithZone:zone];
    
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
    
    self.service = service;
    
    if (params) {
        [self objAllocateValues:params];
    }
    
    return self;
}

- (void)viewModelDidLoad {
    
};


@end
