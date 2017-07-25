//
//  FileManagerView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  文件管理视图

#import "BaseTableView.h"
#import "FileManagerFileLongViewCell.h"
#import "FileManagerFolderLongViewCell.h"

@class FileManagerView;
@protocol FileManagerViewDelegate <NSObject>
@optional
- (void)managerView:(FileManagerView *)managerView didselectedModel:(JHFile *)file;

@end

@interface FileManagerView : UIView<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) BaseTableView *tableView;
@property (copy, nonatomic) NSString *searchKey;
@property (strong, nonatomic) JHFile *currentFile;
@property (weak, nonatomic) id<FileManagerViewDelegate>delegate;
@property (strong, nonatomic, readonly) UILongPressGestureRecognizer *longPressGestureRecognizer;
- (void)refreshingWithAnimate:(BOOL)flag;
- (void)viewScrollToTop:(BOOL)flag;
- (void)reloadDataWithAnimate:(BOOL)flag;
@end
