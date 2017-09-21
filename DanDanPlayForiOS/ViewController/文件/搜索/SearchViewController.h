//
//  SearchViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  搜索

#import "JHBaseViewController.h"

@interface SearchViewController : JHBaseViewController
@property (strong, nonatomic) VideoModel *model;
@property (copy, nonatomic) NSString *keyword;
@end
