//
//  NSObject+Property.m
//  ULove
//
//  Created by Quincy Yan on 16/3/21.
//  Copyright © 2016年 SSKit. All rights reserved.
//

#import "NSObject+Property.h"
#import <objc/runtime.h>

@implementation NSObject (Property)

+ (NSArray *)objAllProperties {
    unsigned int count;
    Ivar *ivarList = class_copyIvarList(self, &count);
    NSMutableArray *keys = [NSMutableArray new];
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        NSString *key = [name substringFromIndex:1];
        [keys addObject:key];
    }
    return keys;
}

- (id)objValueOfKey:(NSString *)key {
    SEL value = NSSelectorFromString(key);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [self performSelector:value];
#pragma clang diagnostic pop
}

- (id)objClassCopy {
    NSArray *keys = [[self class] objAllProperties];
    id class = [[[self class] alloc] init];
    for (NSString *key in keys) {
        [class setValue:[self objValueOfKey:key] forKey:key];
    }
    return class;
}

+ (BOOL)objSearchClass:(Class)aClass hasProperty:(NSString *)property {
    if (aClass == nil) return NO;
    if (property == nil || property.length == 0) return NO;
    
    unsigned int outCount;
    objc_property_t * properties = class_copyPropertyList(aClass , &outCount);
    for (int i = 0; i < outCount; i++) {
        objc_property_t property_t = properties[i];
        NSString *key = [[NSString alloc] initWithCString:property_getName(property_t) encoding:NSUTF8StringEncoding];
        if ([key isEqualToString:property]) {
            free(properties);
            return YES;
        }
    }
    free(properties);
    return NO;
}

- (id)objAllocateValues:(NSDictionary *)params {
    if (params.allKeys.count == 0) return self;
    for (NSString *key in params.allKeys) {
        if ([[self class] objSearchClass:[self class] hasProperty:key]) {
            [self setValue:params[key] forKey:key];
        }
    }
    return self;
}

+ (id)objInitializeWithClass:(NSString *)aClass alsoParams:(NSDictionary *)params {
    if (aClass == nil || aClass.length == 0) return nil;
    
    const char *class = [aClass cStringUsingEncoding:NSASCIIStringEncoding];
    Class newClass = objc_getClass(class);
    if (!newClass) {
        Class superClass = [NSObject class];
        newClass = objc_allocateClassPair(superClass, class, 0);
        objc_registerClassPair(newClass);
    }
    id instance = [[newClass alloc] init];
    return [instance objAllocateValues:params];
}

@end
