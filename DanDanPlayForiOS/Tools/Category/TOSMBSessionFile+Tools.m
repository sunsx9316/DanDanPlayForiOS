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
    TOSMBSession *session = [ToolsManager shareToolsManager].SMBSession;
    //两次URL编码
    NSMutableString *path = [[NSMutableString alloc] initWithString:@"smb://"];
    if (session.userName.length && session.password.length) {
        [path appendFormat:@"%@:%@@", [[session.userName stringByURLEncode] stringByURLEncode], [[session.password stringByURLEncode] stringByURLEncode]];
    }
    else if (session.userName.length && session.password.length == 0) {
        [path appendFormat:@"%@@", [[session.userName stringByURLEncode] stringByURLEncode]];
    }
    
    if (session.ipAddress.length) {
        [path appendString:session.ipAddress];
    }
    
    [path appendFormat:@"%@", [[self.filePath stringByURLEncode] stringByURLEncode]];

    return [NSURL URLWithString:path];
}

@end
