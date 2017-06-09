//
//  QBResponseModel.h
//  Pods
//
//  Created by lizhihui on 2017/1/5.
//
//  定义各个返回字段,进行有效数据解密(原始数据,状态码,时间戳,解密后的有效数据,消息,其他字段)

#import "QBNetModel.h"

@interface QBResponseModel : QBNetModel

@property (nonatomic, strong) id originObj;//!<原始数据.
@property (nonatomic, strong) id result;   //!<解密后的有效数据.
@property (nonatomic, strong) id message;  //!<信息.
@property (nonatomic, strong) id status;   //!<状态码.
@property (nonatomic, strong) id time;     //!<时间戳.
- (instancetype)initWithOriginObj:(id)originObj encyType:(QBCodeType)encyType key:(NSString *)key;//!<初始化.
- (void)startAnalysisResponseData;

#pragma mark 可能需要子类实现的(应答数据中的几个key)
- (NSString *)keyStatus; //!<状态key.
- (NSString *)keyResult; //!<有效数据key.
- (NSString *)keyMessage;//!<消息key.
- (NSString *)keyTime;   //!<时间戳key.
@end
