//
//  QBViewModel.m
//  QBCore
//
//  Created by Qiaokai on 2017/3/2.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import "QBViewModel.h"
#import "NSObject+Property.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface QBViewModel ()

@property (nonatomic, strong, readwrite) RACSubject *errors;
@property (nonatomic, strong, readwrite) RACCommand *requestCommand;


@end

@implementation QBViewModel

@synthesize service = _service;
@synthesize selfController = _selfController;
@synthesize title = _title;
@synthesize showType = _showType;
@synthesize networkState = _networkState;


+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    QBViewModel *viewModel = [super allocWithZone:zone];
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
    @weakify(self);
    self.requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        @strongify(self);
        return [[self loadData] takeUntil:self.rac_willDeallocSignal];
    }];
};

- (RACSubject *)errors {
    if (!_errors) _errors = [RACSubject subject];
    return _errors;
}

- (RACSignal *)loadData {
    return [RACSignal empty];
}

- (void)dealloc {
    NSLog(@"dealloc:%@",NSStringFromClass([self class]));
}

@end
