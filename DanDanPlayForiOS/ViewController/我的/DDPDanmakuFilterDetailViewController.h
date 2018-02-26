//
//  DDPDanmakuFilterDetailViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

#define FILTER_DEFAULT_NAME @"未命名规则"

@interface DDPDanmakuFilterDetailViewController : DDPBaseViewController
@property (strong, nonatomic) DDPFilter *model;
@property (copy, nonatomic) void(^addFilterCallback)(DDPFilter *model);
@end
