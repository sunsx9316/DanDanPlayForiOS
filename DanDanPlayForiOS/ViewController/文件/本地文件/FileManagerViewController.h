//
//  FileManagerViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBaseViewController.h"
#import "JHBaseTableView.h"

@interface FileManagerViewController : JHBaseViewController
@property (strong, nonatomic) JHFile *file;
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
- (void)matchFile:(JHFile *)file;
@end
