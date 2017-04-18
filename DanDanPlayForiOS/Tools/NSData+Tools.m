//
//  NSData+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "NSData+Tools.h"

@implementation NSData (Tools)
- (NSData *)encryptWithDandanplayType {
    NSString *key = DANDANPLAY_KEY;
    NSString *iv = DANDANPLAY_IV;
    return [[NSString stringWithFormat:@"\"%@\"", [[self aes256EncryptWithKey:[NSData dataWithBase64EncodedString:key] iv:[NSData dataWithBase64EncodedString:iv]] base64EncodedString]] dataUsingEncoding:NSUTF8StringEncoding];
}
@end
