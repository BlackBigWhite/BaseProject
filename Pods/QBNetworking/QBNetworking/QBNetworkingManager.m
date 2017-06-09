//
//  QBNetworking.m
//  WKWebDemo
//
//  Created by lizhihui on 2016/12/22.
//  Copyright © 2016年 lizhihui. All rights reserved.
//

#import "QBNetworkingManager.h"
#import "AFNetworking.h"
#import "AFURLResponseSerialization.h"
#import "QBURLSessionWrapperOperation.h"

@interface QBNetworkingManager (){
    BOOL _enableLog;//!<是否打印日志,默认不打印.
    QBNetworkStatus _networkStatus;//!<网络类型.
}
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;//!<sessionManager.
@property (nonatomic, strong) AFNetworkReachabilityManager *netReachabilityManager;//!<net reachability manager.
@end

@implementation QBNetworkingManager

#pragma mark - 初始化方法

+ (instancetype)manager {
    {
        static QBNetworkingManager *sharedManagerInstance = nil;
        static dispatch_once_t predicate;
        dispatch_once(&predicate, ^{
            sharedManagerInstance = [[self alloc] init];
        });
        return sharedManagerInstance;
    }
}

- (instancetype)init {
    if (self = [super init]) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [self responseSerialization];
        _sessionManager.requestSerializer = [self requestSerialization];
        
        _netReachabilityManager = [AFNetworkReachabilityManager sharedManager];
        [_netReachabilityManager startMonitoring];
        [_netReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            _networkStatus = status;
        }];
    }
    return self;
}

- (void)enableLog:(BOOL)enableLog {
    _enableLog = enableLog;
}

- (void)setCertificateNames:(NSArray *)certificateNames {
    _certificateNames = [certificateNames copy];
    if (certificateNames.count > 0) {
        _sessionManager.securityPolicy = [self customSecurityPolicy];//!<安全策略.
    }
}

#pragma mark - get请求

- (NSURLSessionDataTask *)GET:(QBRequestModel *)model successBlock:(networkingSuccessBlock)successBlock failBlock:(networkingfailBlock)failBlock {
    NSDate *satrtDate = [NSDate date];

    //!<添加头部信息.
    [self addHeaderInfo:[model httpHeader] toRequestSerializer:_sessionManager.requestSerializer];
    
    NSURLSessionDataTask *task = [_sessionManager GET:model.url parameters:[model encodeParaIfNeeded] progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (_enableLog) {
            NetLog(@"响应内容:%@", responseObject);
            NetLog(@"请求用时:%f",[[NSDate date] timeIntervalSinceDate:satrtDate]);
            NetLog(@"******************************请求完成(%zi)******************************\n\n",task.taskIdentifier);
        }
        //!<创建model.
        QBResponseModel *responseModel = [[QBResponseModel alloc] initWithOriginObj:responseObject encyType:model.encyType key:model.key];
        //!<解析数据.
        [responseModel startAnalysisResponseData];
        //!<返回model.
        if (successBlock) {
            successBlock(responseModel);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (failBlock) {
            failBlock(error);
        }
    }];
    if (_enableLog) {
        NetLog(@"******************************请求开始(%zi)******************************",task.taskIdentifier);
        NetLog(@"请求地址:%@",model.url);
        NetLog(@"请求头信息:%@",task.originalRequest.allHTTPHeaderFields);
        NetLog(@"请求原始内容:%@",model.para);
        NSString *body = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
        NetLog(@"请求内容:%@",[body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    return task;
}

#pragma mark - post请求

- (NSURLSessionDataTask *)POST:(QBRequestModel *)model successBlock:(networkingSuccessBlock)successBlock failBlock:(networkingfailBlock)failBlock {
    NSDate *satrtDate = [NSDate date];

    //!<添加头部信息.
    [self addHeaderInfo:[model httpHeader] toRequestSerializer:_sessionManager.requestSerializer];
    
    NSURLSessionDataTask *task = [_sessionManager POST:model.url parameters:[model encodeParaIfNeeded] progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (_enableLog) {
            NetLog(@"响应内容:%@", responseObject);
            NetLog(@"请求用时:%f",[[NSDate date] timeIntervalSinceDate:satrtDate]);
            NetLog(@"******************************请求完成(%zi)******************************\n\n",task.taskIdentifier);
        }
        //!<创建model.
        QBResponseModel *responseModel = [[QBResponseModel alloc] initWithOriginObj:responseObject encyType:model.encyType key:model.key];
        //!<解析数据.
        [responseModel startAnalysisResponseData];
        //!<返回model.
        if (successBlock) {
            successBlock(responseModel);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (failBlock) {
            failBlock(error);
        }
    }];
    if (_enableLog) {
        NetLog(@"******************************请求开始(%zi)******************************",task.taskIdentifier);
        NetLog(@"请求地址:%@",model.url);
        NetLog(@"请求头信息:%@",task.originalRequest.allHTTPHeaderFields);
        NetLog(@"请求原始内容:%@",model.para);
        NSString *body = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
        NetLog(@"请求内容:%@",[body stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    return task;
}

#pragma mark - 批处理请求
- (void)batchOfRequestTasks:(NSArray<NSURLSessionDataTask *> *)tasks progressBlock:(nullable void (^)(NSUInteger numberOfFinishedTasks, NSUInteger totalNumberOfTasks))progressBlock completionBlock:(nullable void (^)(NSArray<NSURLSessionDataTask *> *tasks))completionBlock {
    if (_enableLog) {
        NetLog(@"******************************批处理开始******************************");
    }
    NSDate *satrtDate = [NSDate date];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 5;
    __block NSUInteger finishedTasks = 0;
    NSBlockOperation *completionOperation = [NSBlockOperation blockOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{//回到主线程执行
            if (_enableLog) {
                NetLog(@"批处理用时:%f",[[NSDate date] timeIntervalSinceDate:satrtDate]);
                NetLog(@"******************************批处理结束******************************");
            }
            if (completionBlock) {
                completionBlock(tasks);
            }
        }];
    }];
    for (NSURLSessionDataTask *task in tasks) {
        QBURLSessionWrapperOperation *operation = [QBURLSessionWrapperOperation operationWithURLSessionTask:task];
        [completionOperation addDependency:operation];
        [queue addOperation:operation];
        [operation setCompletionBlock:^{
            finishedTasks++;
            progressBlock(finishedTasks,tasks.count);
        }];
    }
    [queue addOperation:completionOperation];
}

#pragma mark - 文件上传
- (NSURLSessionDataTask *)uploadImage:(UIImage *)image requestModel:(QBRequestModel *)model progressBlock:(void (^)(NSProgress *uploadProgress)) progressBlock successBlock:(networkingSuccessBlock)successBlock failBlock:(networkingfailBlock)failBlock {
    NSDate *satrtDate = [NSDate date];

    //!<添加头部信息.
    [self addHeaderInfo:[model httpHeader] toRequestSerializer:_sessionManager.requestSerializer];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURLSessionDataTask *task = [_sessionManager POST:model.url parameters:[model encodeParaIfNeeded] constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        /***** 在这里直接添加上传的图片 *****/
        NSData *data = UIImagePNGRepresentation(image);

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        str = [NSString stringWithFormat:@"%@%@",str,arc4random()%10000];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        /*
         此方法参数
         1. 要上传的[二进制数据]
         2. 对应网站上[upload.php中]处理文件的[字段"file"]
         3. 要保存在服务器上的[文件名]
         4. 上传文件的[mimeType]
         */
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/png"];
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if(progressBlock){progressBlock(uploadProgress);}
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (_enableLog) {
            NetLog(@"响应内容:%@", responseObject);
            NetLog(@"请求用时:%f",[[NSDate date] timeIntervalSinceDate:satrtDate]);
            NetLog(@"******************************请求完成(%zi)******************************\n\n",task.taskIdentifier);
        }
        //!<创建model.
        QBResponseModel *responseModel = [[QBResponseModel alloc] initWithOriginObj:responseObject encyType:model.encyType key:model.key];
        //!<解析数据.
        [responseModel startAnalysisResponseData];
        //!<返回model.
        if (successBlock) {
            successBlock(responseModel);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (failBlock) {
            failBlock(error);
        }
    }];
    
    if (_enableLog) {
        NetLog(@"******************************请求开始(%zi)******************************",task.taskIdentifier);
        NetLog(@"请求地址:%@",model.url);
        NetLog(@"请求头信息:%@",task.originalRequest.allHTTPHeaderFields);
        NSData *data = UIImagePNGRepresentation(image);
        NetLog(@"上传图片:%@-大小:%kb",image,data.length/1024);
    }
    return task;
}

#pragma mark - getter methods
- (QBNetworkStatus)networkStatus {
    return _networkStatus;
}

#pragma mark - private methods

#pragma mark 应答数据序列化对象
- (AFJSONResponseSerializer *)responseSerialization {
    AFJSONResponseSerializer *serialization = [AFJSONResponseSerializer serializer];
    serialization.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
    return serialization;
}

- (AFJSONResponseSerializer *)requestSerialization {
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setTimeoutInterval:120];//!<超时控制.
    return requestSerializer;
}

#pragma mark 自定义安全策略
- (AFSecurityPolicy *)customSecurityPolicy {//!<自定义安全策略.
    //!<需要的证书.
    NSMutableArray *cers = [NSMutableArray array];
    for (NSString *cerName in self.certificateNames) {
        NSString *cerPath = [[NSBundle mainBundle] pathForResource:cerName ofType:@"cer"];//证书的路径
        NSData *certData = [NSData dataWithContentsOfFile:cerPath];
        if (certData.length != 0) {
            [cers addObject:certData];
        }
    }
    // AFSSLPinningModeCertificate 使用证书验证模式
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    //allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    //如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = [NSSet setWithArray:cers];
    return securityPolicy;
}

#pragma mark 添加头部信息
- (void)addHeaderInfo:(NSDictionary *)info toRequestSerializer:(AFHTTPRequestSerializer *)requestSerializer {
    [info enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [requestSerializer setValue:obj forHTTPHeaderField:key];
    }];
}

@end
