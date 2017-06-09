//
//  NSObject+Property.h
//  ULove
//
//  Created by Quincy Yan on 16/3/21.
//  Copyright © 2016年 SSKit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Property)

/**
 获取类中的所有参数
 */
+ (NSArray *)objAllProperties;

/**
 获取类中的一个属性的值
 */
- (id)objValueOfKey:(NSString *)key;

/**
 完全复制一个类
 */
- (id)objClassCopy;

/**
 搜索一个类中是否有该属性名
 */
+ (BOOL)objSearchClass:(Class)aClass hasProperty:(NSString *)property;

/**
 对一个对象进行赋值
 */
- (id)objAllocateValues:(NSDictionary *)params;

/**
 根据名称初始化一个对象
 */
+ (id)objInitializeWithClass:(NSString *)aClass alsoParams:(NSDictionary *)params;

@end
