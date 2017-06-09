//
//  QBResponseModel.m
//  Pods
//
//  Created by lizhihui on 2017/1/5.
//
//

#import "QBResponseModel.h"

@implementation QBResponseModel

- (instancetype)initWithOriginObj:(id)originObj encyType:(QBCodeType)encyType key:(NSString *)key {
    self = [super init];
    if (self) {
        self.originObj = originObj;
        self.key = [key copy];
        self.encyType = encyType;
    }
    return self;
}

- (void)startAnalysisResponseData {
    //!<有效数据.
    NetLog(@"**************************--result部分--解密--开始******************\n");
    id validData = nil;
    if (self.encyType == QBCodeTypeNone) {
        validData = [self.originObj objectForKey:[self keyResult]];
    }else {
        NSString *decodeStr = [self.originObj objectForKey:[self keyResult]];
        validData = [self decodeObj:decodeStr key:self.key decodeType:self.encyType];
    }
    self.result = validData;
    NetLog(@"result加密内容:\n%@",validData);
    NetLog(@"**************************--result部分--解密--完成******************\n\n\n");
    //!<信息.
    self.message = [self.originObj objectForKey:[self keyMessage]];
    NetLog(@"响应信息:%@",self.message);
    //!<状态码.
    self.status = [self.originObj objectForKey:[self keyStatus]];
    NetLog(@"响应状态码:%@",self.status);
    //!<时间戳.
    self.time = [self.originObj objectForKey:[self keyTime]];
    NetLog(@"时间戳:%@",self.time);

}

- (NSString *)keyStatus {return @"status";}

- (NSString *)keyResult {return @"result";}

- (NSString *)keyMessage {return @"message";}

- (NSString *)keyTime {return @"time";}
@end
