//
//  QBNavBarCustom.m
//  导航控制器
//
//  Created by lizhihui on 2017/3/3.
//  Copyright © 2017年 lizhihui. All rights reserved.
//

#import "QBNavBarCustom.h"
#import <Masonry/Masonry.h>
#import "QBToolbarCustom.h"

#define screen_width [[UIScreen mainScreen] bounds].size.width
#define statusbar_height [[UIApplication sharedApplication] statusBarFrame].size.height
#define max_buttom_item_width  44

@interface QBNavBarCustom (){
    UIToolbar *_toolBar;
    UIBarButtonItem *_fixedMarginSpaceItem;
    UILabel *_titleLabel;
    UIImageView *_backgroundImageView;
    CGFloat _marginSpacing;
}
@end

@implementation QBNavBarCustom

#pragma mark - 初始化

+ (instancetype)customNavBar {
    QBNavBarCustom *bar = [[QBNavBarCustom alloc] initWithFrame:CGRectMake(0, 0, screen_width, 64)];
    return bar;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        __weak typeof(self)weakSelf = self;
        //!<背景图片.
        _backgroundImageView = [UIImageView new];
        [self addSubview:_backgroundImageView];
        [_backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.top.and.bottom.equalTo(weakSelf);
        }];
        
        //!<工具条.
        _toolBar = [QBToolbarCustom new];_toolBar.clipsToBounds = YES;
        [self addSubview:_toolBar];
        [_toolBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(weakSelf);
            make.height.equalTo(weakSelf.mas_height).offset(-statusbar_height);
        }];
        
        _titleLabel = [UILabel new];_titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.mas_top).offset(statusbar_height);
            make.bottom.equalTo(weakSelf.mas_bottom);
            make.left.equalTo(weakSelf.mas_left).offset(screen_width/2);
            make.right.equalTo(weakSelf.mas_right).offset(-screen_width/2);
        }];
        
        self.marginSpacing = 16;
        _fixedMarginSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        
    }
    return self;
}

#pragma mark - setter methods

- (void)setLeftBarButtonItem:(UIBarButtonItem *)leftBarButtonItem {
    _leftBarButtonItem = leftBarButtonItem;
    _leftBarButtonItems = @[leftBarButtonItem];
    leftBarButtonItem.tintColor = _tintColor;
    [self resetItems];
}

- (void)setLeftBarButtonItems:(NSArray<UIBarButtonItem *> *)leftBarButtonItems {
    _leftBarButtonItems = leftBarButtonItems;
    _leftBarButtonItem = leftBarButtonItems.firstObject;
    for (UIBarButtonItem *obj in leftBarButtonItems) {
        obj.tintColor = _tintColor;
    }
    [self resetItems];
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)rightBarButtonItem {
    _rightBarButtonItem = rightBarButtonItem;
    _rightBarButtonItems = @[_rightBarButtonItems];
    _rightBarButtonItem.tintColor = _tintColor;
    [self resetItems];
}

- (void)setRightBarButtonItems:(NSArray<UIBarButtonItem *> *)rightBarButtonItems {
    _rightBarButtonItems = rightBarButtonItems;
    _rightBarButtonItem = rightBarButtonItems.firstObject;
    for (UIBarButtonItem *obj in rightBarButtonItems) {
        obj.tintColor = _tintColor;
    }
    [self resetItems];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _titleLabel.hidden = NO;

    _titleLabel.attributedText = [[NSAttributedString alloc] initWithString:title attributes:_titleTextAttributes];
    
    [_titleView removeFromSuperview];_titleView = nil;
    
    [self setNeedsLayout];
}

- (void)setTitleView:(UIView *)titleView {
    _titleView = titleView;
    _titleLabel.hidden = YES;
    __weak typeof(self)weakSelf = self;
    [self addSubview:_titleView];
    [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(weakSelf);
        make.size.mas_equalTo(CGSizeMake(CGRectGetWidth(titleView.bounds), CGRectGetHeight(titleView.bounds)));
    }];
}

- (void)setMarginSpacing:(CGFloat)marginSpacing {
    _marginSpacing = marginSpacing - 16;
    _fixedMarginSpaceItem.width = _marginSpacing;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    _backgroundImage = backgroundImage;
    _backgroundImageView.image = backgroundImage;
}

#pragma mark - getter methods

- (CGFloat)marginSpacing {
    return _marginSpacing + 16;
}

#pragma mark - core code

- (void)resetItems {
    //!<重新设置bool bar.
    NSMutableArray *items = [NSMutableArray array];
    
    [items addObject:_fixedMarginSpaceItem];
    
    for (UIBarButtonItem *obj in _leftBarButtonItems) {
        [items addObject:obj];
        if (obj != _leftBarButtonItems.lastObject) {
            UIBarButtonItem *fixedSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            [items addObject:fixedSpaceItem];
        }
    }
    
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [items addObject:flexibleSpaceItem];
    
    for (UIBarButtonItem *obj in _rightBarButtonItems) {
        [items addObject:obj];
        if (obj != _rightBarButtonItems.lastObject) {
            UIBarButtonItem *fixedSpaceItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            [items addObject:fixedSpaceItem];
        }
    }
    
    [items addObject:_fixedMarginSpaceItem];
    
    _toolBar.items = items;
    
}

- (void)itemSpacing:(CGFloat)spacing Between:(NSInteger)index1 and:(NSInteger)index2 on:(nullable NSArray<UIBarButtonItem *> *)items {
    UIBarButtonItem *index1Btn = (UIBarButtonItem *)[items objectAtIndex:index1];
    NSInteger newIndex1 = [_toolBar.items indexOfObject:index1Btn];
    if (_toolBar.items.count > newIndex1+1 && [index1Btn isKindOfClass:[UIBarButtonItem class]]) {
        UIBarButtonItem *fixedSpaceItem = [_toolBar.items objectAtIndex:newIndex1+1];
        fixedSpaceItem.width = spacing;
        [_toolBar setNeedsLayout];
    }
}

#pragma mark - private methods

- (CGFloat)getSignalStringWidth:(NSAttributedString *)aString StringAttributes:(NSDictionary<NSString *,id> *)att width:(CGFloat)width height:(CGFloat)height {
    
    CGSize strSize = [[aString string] boundingRectWithSize:CGSizeMake(width, height)
                                                    options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                 attributes:att
                                                    context:nil].size;
    
    return strSize.width + 5;//!<+1:弥补该方法带来的误差.
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_titleLabel.hidden) {
        CGFloat width_all = self.marginSpacing*2;
        CGFloat spacing_left;
        CGFloat spacing_right = CGFLOAT_MAX;
        
        for (UIView *obj in _toolBar.subviews) {
            width_all += obj.bounds.size.width;
            if (CGRectGetMaxX(obj.frame) <= screen_width/2 && spacing_left < CGRectGetMaxX(obj.frame)) {
                spacing_left = CGRectGetMaxX(obj.frame);
            }
            if (CGRectGetMinX(obj.frame) > screen_width/2 && spacing_right > CGRectGetMinX(obj.frame)) {
                spacing_right = CGRectGetMinX(obj.frame);
            }
        }
        for (UIBarButtonItem *obj in _toolBar.items) {
            width_all += obj.width;
        }
        CGFloat new_width = [self getSignalStringWidth:_titleLabel.attributedText StringAttributes:_titleTextAttributes width:1000 height:44];
        CGFloat width_available = screen_width - width_all;
        
        __weak typeof(self)weakSelf = self;
        if (new_width < width_available) {
            CGFloat offset = (screen_width - width_available)/2;
            [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                //!<8:冗余位.
                make.left.equalTo(weakSelf.mas_left).offset(offset+8);
                make.right.equalTo(weakSelf.mas_right).offset(-offset-8);
            }];
        }else {
            //!<8:冗余位.
            [_titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakSelf.mas_left).offset(spacing_left+8);
                make.right.equalTo(weakSelf.mas_right).offset(spacing_right-screen_width-8);
            }];
        }
        
    }
}

@end
