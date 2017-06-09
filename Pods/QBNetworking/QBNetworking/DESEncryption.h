//
//  DESEncryption.h
//  QianBao
//
//  Created by WDL on 15/12/18.
//  Copyright © 2015年 wudeliang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DESEncryption : NSObject

/** 解密*/
+(NSString*) decryptUseDES:(NSString*)cipherText key:(NSString*)key;
+(NSString*) decryptUseDES_3:(NSString*)cipherText key:(NSString*)key;

/** 加密*/
+(NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key;
+(NSString *) encryptUseDES_3:(NSString *)clearText key:(NSString *)key;

@end
