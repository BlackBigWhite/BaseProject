//
//  QBWebViewModel.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBWebViewModel.h"
#import "NSObject+Property.h"

@implementation QBWebViewModel

- (instancetype)initWithService:(id<QBViewModelService>)service fetchParams:(NSDictionary *)params {
    self = [super init];
    if (!self) return nil;
    self.service = service;
    self.shouldShowProgress = YES;
    self.scrollEnabled = YES;
    self.isUseWebPageTitle = YES;
    
    if (params) {
        [self objAllocateValues:params];
    }
    return self;
}


- (void)viewModelDidLoad {
    [super viewModelDidLoad];
    
}

@end
