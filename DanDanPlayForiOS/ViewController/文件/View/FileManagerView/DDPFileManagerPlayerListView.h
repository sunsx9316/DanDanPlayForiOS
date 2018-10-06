//
//  DDPFileManagerPlayerListView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放列表

#import <UIKit/UIKit.h>

@class DDPFileManagerPlayerListView, DDPBaseTableView;
@protocol DDPFileManagerPlayerListViewDelegete <NSObject>
@optional
- (void)managerView:(DDPFileManagerPlayerListView *)managerView didselectedModel:(DDPFile *)file;

@end

@interface DDPFileManagerPlayerListView : UIView
@property (strong, nonatomic, readonly) DDPBaseTableView *tableView;
@property (strong, nonatomic) DDPFile *currentFile;
@property (weak, nonatomic) id<DDPFileManagerPlayerListViewDelegete> delegate;
- (void)scrollToCurrentFile;
@end
