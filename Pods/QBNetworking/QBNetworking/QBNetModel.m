//
//  QBNetModel.m
//  Pods
//
//  Created by lizhihui on 2017/1/5.
//
//

#import "QBNetModel.h"
#import "DESEncryption.h"

@implementation QBNetModel

- (NSString *)encodeObj:(NSDictionary *)obj key:(NSString *)key encodeType:(QBCodeType)encodeType {
    NSString *json = nil;
    NSString *objStr = [self jsonStrFromDic:obj];
    switch (encodeType) {
        case QBCodeTypeDES:{
            json = [DESEncryption encryptUseDES:(NSString *)objStr key:key];
            break;
        }
        case QBCodeTypeDES3:{
            json = [DESEncryption encryptUseDES_3:(NSString *)objStr key:key];
            break;
        }
        default:
            break;
    }
    return json;
}

- (NSDictionary *)decodeObj:(NSString *)obj key:(NSString *)key decodeType:(QBCodeType)decodeType {
    id  json = nil;
    if ([obj isKindOfClass:[NSString class]]) {//!<是字符串的进行解析.
        switch (decodeType) {
            case QBCodeTypeDES:{
                NSString * desStr = [DESEncryption decryptUseDES:(NSString *)obj key:key];
                NSData *data = [desStr dataUsingEncoding:NSUTF8StringEncoding];
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                break;
            }
            case QBCodeTypeDES3:{
                NSString * desStr = [DESEncryption decryptUseDES_3:(NSString *)obj key:key];
                NSData *data = [desStr dataUsingEncoding:NSUTF8StringEncoding];
                json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                
                break;
            }
            default:
                break;
        }
    }
    return json;
}

#pragma mark - private methods
#pragma mark 字典转json串
- (NSString *)jsonStrFromDic:(id)obj {//!<obj转json串.
    if (obj == nil) {
        return nil;
    }
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *dictStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return dictStr;
}
@end
