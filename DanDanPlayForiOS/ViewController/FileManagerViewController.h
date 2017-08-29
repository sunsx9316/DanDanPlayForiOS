//
//  FileManagerViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseViewController.h"
#import "BaseTableView.h"

@interface FileManagerViewController : BaseViewController
@property (strong, nonatomic) JHFile *file;
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
- (void)matchFile:(JHFile *)file;
@end
