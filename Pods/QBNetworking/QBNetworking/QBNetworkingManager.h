//
//  QBNetworking.h
//  WKWebDemo
//
//  Created by lizhihui on 2016/12/22.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBRequestModel.h"
#import "QBResponseModel.h"

typedef void(^networkingSuccessBlock)(QBResponseModel *responseObj);
typedef void(^networkingfailBlock)(NSError *error);

typedef NS_ENUM(NSUInteger, QBNetworkStatus) {
    QBNetworkStatusUnknown          = -1,//!<未知.
    QBNetworkStatusNotReachable     = 0, //!<不可达.
    QBNetworkStatusReachableViaWWAN = 1, //!<基站.
    QBNetworkStatusReachableViaWiFi = 2, //!<wifi.
};

@interface QBNetworkingManager : NSObject
@property (nonatomic, assign, readonly) QBNetworkStatus networkStatus;//!<网络类型.
/**
 证书的名字,扩展名需要是.cer,如果使用了https传输协议且申请的证书是不可信的,必须导入证书到工程.
 */
@property (nonatomic, strong) NSArray *certificateNames;

+ (instancetype)manager;//!<网络请求的单利.

- (void)enableLog:(BOOL)enableLog;//!<是否打印日志.
/**
 *  @brief get请求api
 *
 *  @param1 model  字符型地址(包含url,加密方式,参数)  必填:是
 *  @param3 successBlock  请求成功block  必填:非
 *  @param4 failBlock  请求失败block  必填:非
 *
 *  return 会话
 */

- (NSURLSessionDataTask *)GET:(QBRequestModel *)model successBlock:(networkingSuccessBlock)successBlock failBlock:(networkingfailBlock)failBlock;

/**
 *  @brief post请求api
 *
 *  @param1 model  字符型地址(包含url,加密方式,参数)  必填:是
 *  @param3 successBlock  请求成功block  必填:非
 *  @param4 failBlock  请求失败block  必填:非
 *
 *  return 会话
 */
- (NSURLSessionDataTask *)POST:(QBRequestModel *)model successBlock:(networkingSuccessBlock)successBlock failBlock:(networkingfailBlock)failBlock;
/**
 *  @brief 批量请求api
 *
 *  @param1 tasks  任务s  必填:是
 *  @param3 progressBlock    批处理过程block  必填:非
 *  @param4 completionBlock  批处理完成block  必填:非
 *
 *  return 会话
 */
- (void)batchOfRequestTasks:(NSArray<NSURLSessionDataTask *> *)tasks progressBlock:(nullable void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock completionBlock:(nullable void (^)(NSArray<NSURLSessionDataTask *> *tasks))completionBlock;
/**
 *  @brief 图片上传api
 *
 *  @param1 image  需要上传的图片  必填:是
 *  @param2 tasks  参数          必填:非
 *  @param3 progressBlock    上传进度block    必填:非
 *  @param4 progressBlock    批处理过程block  必填:非
 *  @param5 completionBlock  批处理完成block  必填:非
 *
 *  return 会话
 */
- (NSURLSessionDataTask *)uploadImage:(UIImage *)image requestModel:(QBRequestModel *)model progressBlock:(void (^)(NSProgress *uploadProgress)) progressBlock successBlock:(networkingSuccessBlock)successBlock failBlock:(networkingfailBlock)failBlock;
@end
