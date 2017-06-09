//
//  QBViewController.h
//  QBCore
//
//  Created by Qiaokai on 2017/3/3.
//  Copyright © 2017年 QianBao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QBViewModel.h"
#import "QBViewControlleProtocol.h"
#import <QBNavBarCustom/QBNavBarCustom.h>

@interface QBViewController : UIViewController <QBViewControlleProtocol>
@property (nonatomic, strong) QBNavBarCustom *navigationBar;//!<自定义导航栏.
@end
