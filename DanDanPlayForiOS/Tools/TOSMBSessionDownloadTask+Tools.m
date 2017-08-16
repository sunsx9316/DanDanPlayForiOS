//
//  TOSMBSessionDownloadTask+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "TOSMBSessionDownloadTask+Tools.h"

@implementation TOSMBSessionDownloadTask (Tools)

- (float)progress {
    return self.countOfBytesReceived * 1.0 / self.countOfBytesExpectedToReceive;
}

@end
