//
//  QBTableViewModel.m
//  QBBaseProjectFrame
//
//  Created by lizhihui on 2017/3/9.
//  Copyright © 2017年 qianbao. All rights reserved.
//

#import "QBTableViewModel.h"

@interface QBTableViewModel ()

@property (nonatomic, strong, readwrite) RACCommand *requestDataCommand;
@property (nonatomic, strong, readwrite) RACCommand *requestLoadMoreDataCommand;

@end

@implementation QBTableViewModel
@synthesize dataSource = _dataSource;
@synthesize page = _page;
@synthesize didSelectCommand = _didSelectCommand;
@synthesize viewModel = _viewModel;
@synthesize rowHeight = _rowHeight;

- (void)viewModelDidLoad {
    [super viewModelDidLoad];
    self.rowHeight = 44;
    self.page = 1;
    @weakify(self);
    self.requestDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        return [[self requestDataSignal] takeUntil:self.rac_willDeallocSignal];
    }];
    self.requestLoadMoreDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        return [[self requestLoadMoreDataSignal] takeUntil:self.rac_willDeallocSignal];
    }];
}

/**
 请求数据，结果以信号形式返还
 
 @return RACSignal
 */
- (RACSignal *)requestDataSignal {
    return [RACSignal empty];
}

- (RACSignal *)requestLoadMoreDataSignal {
    return [RACSignal empty];
}

@end
