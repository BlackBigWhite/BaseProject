//
//  QBViewControlleProtocol.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/6.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBViewModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QBViewModelProtocol;
@protocol QBViewControlleProtocol <NSObject>

@required

@property (nullable, nonatomic, strong, readonly) id<QBViewModelProtocol> viewModel;

- (instancetype)initWithViewModel:(id<QBViewModelProtocol>)viewModel;

- (void)bindViewModel;

@end

NS_ASSUME_NONNULL_END
