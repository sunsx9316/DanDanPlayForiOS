//
//  TOSMBSessionFile+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "TOSMBSessionFile+Tools.h"

@implementation TOSMBSessionFile (Tools)

- (NSURL *)fullURL {
    //smb://xiaoming:123456@192.168.1.100/xiaoming/Desktop/1.mp4
    TOSMBSession *session = [ToolsManager shareSMBSession];
    //两次URL编码
    NSString *aStr = [NSString stringWithFormat:@"smb://%@:%@@%@%@", [[session.userName stringByURLEncode] stringByURLEncode], session.password, session.ipAddress, [[self.filePath stringByURLEncode] stringByURLEncode]];
    NSString* encodedString = aStr;
    
    return [NSURL URLWithString:encodedString];
}

@end
