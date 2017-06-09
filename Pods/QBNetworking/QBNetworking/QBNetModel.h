//
//  QBNetModel.h
//  Pods
//
//  Created by lizhihui on 2017/1/5.
//
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, QBCodeType) {
    QBCodeTypeNone, //!<不加密.
    QBCodeTypeDES,  //!<DES加密.
    QBCodeTypeDES3, //!<DES3加密.
};

@interface QBNetModel : NSObject
@property (nonatomic, strong) NSString *key;//!<秘钥.
@property (nonatomic, assign) QBCodeType encyType;//!<加密方式,加密模式下,key才有效.

#pragma mark - 为子类提供的基础服务
- (NSString *)encodeObj:(NSDictionary *)obj key:(NSString *)key encodeType:(QBCodeType)encodeType;    //!<根据秘钥/加密方式对obj进行加密.
- (NSDictionary *)decodeObj:(NSString *)obj key:(NSString *)key decodeType:(QBCodeType)decodeType;//!<根据秘钥/加密方式对obj进行解密.

@end
