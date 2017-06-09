//
//  QBNavigationController.h
//  QBBaseProjectFrame
//
//  Created by Qiaokai on 2017/3/7.
//  Copyright © 2017年 qianbao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBNavigationViewModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface QBNavigationController : UINavigationController

@property (nullable, nonatomic, strong, readonly) id viewModel;

- (instancetype)initWithViewModel:(id)viewModel rootViewController:(id)root;

@end
NS_ASSUME_NONNULL_END
