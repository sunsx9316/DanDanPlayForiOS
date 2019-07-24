//
//  DDPEncrypter.h
//  DDPEncrypt
//
//  Created by JimHuang on 2017/11/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPEncrypter : NSObject

/**
 加密

 @param obj 加密对象 可以是NSData、NSString或者可以转成json的数据结构
 @return 密文字节流
 */
UIKIT_EXTERN NSString *ddplay_encryption(id obj);

/**
 解密

 @param str 解密字符串
 @return 解密密文
 */
UIKIT_EXTERN NSString *ddplay_decryption(NSString *str);

@end
