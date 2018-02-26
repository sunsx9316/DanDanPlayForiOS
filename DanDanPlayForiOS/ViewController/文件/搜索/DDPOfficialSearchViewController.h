//
//  DDPOfficialSearchViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  官方搜索

#import "DDPBaseViewController.h"

@interface DDPOfficialSearchViewController : DDPBaseViewController
@property (strong, nonatomic) DDPVideoModel *model;
@property (copy, nonatomic) NSString *keyword;
@end
