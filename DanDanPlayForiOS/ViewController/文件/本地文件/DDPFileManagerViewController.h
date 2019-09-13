//
//  DDPFileManagerViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"
#import "DDPBaseTableView.h"

@interface DDPFileManagerViewController : DDPBaseViewController
@property (strong, nonatomic) DDPFile *file;
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@end
