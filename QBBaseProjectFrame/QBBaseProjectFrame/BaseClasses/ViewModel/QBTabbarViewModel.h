//
//  QBTabbarViewModel.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRouter.h"
#import "QBTabBarViewModelProtocol.h"

@interface QBTabbarViewModel : NSObject <QBTabBarViewModelProtocol>
@property (nonatomic, strong) NSString *configFileName;//!<配置文件.
@end
