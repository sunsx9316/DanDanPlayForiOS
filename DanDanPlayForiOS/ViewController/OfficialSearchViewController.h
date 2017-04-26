//
//  OfficialSearchViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  官方搜索

#import "BaseViewController.h"

@interface OfficialSearchViewController : BaseViewController
@property (strong, nonatomic) VideoModel *model;
@property (copy, nonatomic) NSString *keyword;
@end
