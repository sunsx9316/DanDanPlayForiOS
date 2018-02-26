//
//  DDPSearchViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  搜索

#import "DDPBaseViewController.h"

@interface DDPSearchViewController : DDPBaseViewController
@property (strong, nonatomic) DDPVideoModel *model;
@property (copy, nonatomic) NSString *keyword;
@end
