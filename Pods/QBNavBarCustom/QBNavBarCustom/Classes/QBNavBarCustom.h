//
//  QBNavBarCustom.h
//  导航控制器
//
//  Created by lizhihui on 2017/3/3.
//  Copyright © 2017年 lizhihui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBNavBarCustom : UIView
+ (nullable instancetype)customNavBar;
//!<导航栏按钮,标题,标题视图.
@property(nullable,nonatomic,strong) UIBarButtonItem *leftBarButtonItem;
@property(nullable,nonatomic,strong) UIBarButtonItem *rightBarButtonItem;
@property(nullable,nonatomic,copy) NSArray<UIBarButtonItem *> *leftBarButtonItems;
@property(nullable,nonatomic,copy) NSArray<UIBarButtonItem *> *rightBarButtonItems;
@property(nonatomic,strong,nullable) NSString *title;//!<标题.
@property(nonatomic,strong,nullable) UIView   *titleView;//!<标题视图,需指定尺寸.
//!<样式控制.
@property (nonatomic,strong,nullable) UIImage *backgroundImage;//!<背景图片.
@property(nonatomic,assign) CGFloat marginSpacing;//!<按钮距离屏幕边缘的距离,默认是16.
@property(nonatomic,strong,nullable) UIColor *tintColor;
@property(nullable,nonatomic,copy) NSDictionary<NSString *,id> *titleTextAttributes;
//!<定制导航栏中第index1和index2之间的距离,从0开始.
- (void)itemSpacing:(CGFloat)spacing Between:(NSInteger)index1 and:(NSInteger)index2 on:(nullable NSArray<UIBarButtonItem *> *)items;
@end
