//
//  DanDanPlayEncipher.h
//  DanDanPlayEncrypt
//
//  Created by JimHuang on 2017/11/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DanDanPlayEncipher : NSObject

/**
 加密

 @param text 加密字符串
 @return 密文
 */
UIKIT_EXTERN NSString *ddplay_encryption(NSString *text);

/**
 加密

 @param data 加密字节流
 @return 密文
 */
UIKIT_EXTERN NSString *ddplay_encryptionData(NSData *data);

/**
 加密

 @param obj 加密对象
 @return 密文字节流
 */
UIKIT_EXTERN NSData *ddplay_encryptionObj(id obj);

/**
 解密

 @param text 解密字符串
 @return 原文
 */
UIKIT_EXTERN NSString *ddplay_decryption(NSString *text);

@end
