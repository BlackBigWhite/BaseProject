//
//  QBNetModel.m
//  Pods
//
//  Created by lizhihui on 2017/1/4.
//
//

#import "QBRequestModel.h"
#import "DESEncryption.h"

@implementation QBRequestModel
#pragma mark - 加密参数
- (NSDictionary *)encodeParaIfNeeded {
    if (self.encyType == QBCodeTypeNone) {
        return self.para;
    }else {
        NSString *jsonStr = [self encodeObj:self.para key:self.key encodeType:self.encyType];
        return @{self.keyContent:jsonStr};
    }
}

- (NSString *)keyContent {
    return @"content";
}

- (NSDictionary *)httpHeader {//!<请求头部信息,请按需实现.
    return nil;
}

@end
