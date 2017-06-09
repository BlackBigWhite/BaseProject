//
//  QBURLSessionWrapperOperation.h
//  Pods
//
//  Created by lizhihui on 2017/1/9.
//
//

#import <Foundation/Foundation.h>

@interface QBURLSessionWrapperOperation : NSOperation
+ (instancetype)operationWithURLSessionTask:(NSURLSessionTask*)task;
@end
