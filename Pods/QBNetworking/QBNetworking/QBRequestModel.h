//
//  QBNetModel.h
//  Pods
//
//  Created by lizhihui on 2017/1/4.
//
//  初始化URL,参数,进行数据加密

#import "QBNetModel.h"

@interface QBRequestModel : QBNetModel
@property (nonatomic, strong) NSString *url;//!<请求地址.
@property (nonatomic, strong) NSDictionary *para;//!<请求参数.
- (NSDictionary *)encodeParaIfNeeded;

#pragma mark - 可能需要子类实现的
- (NSDictionary *)httpHeader;//!<请求头部信息,请按需实现.
- (NSString *)keyContent;//!<密文下参数.
@end
