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
    let session = [DDPToolsManager shareToolsManager].SMBSession;
    
    NSURLComponents *components = [[NSURLComponents alloc] init];
    components.scheme = @"smb";
    components.host = session.ipAddress;
    components.path = self.filePath;
    NSURL *url = components.URL;
    return url;
}

@end
