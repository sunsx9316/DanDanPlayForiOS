//
//  FileManagerPlayerListView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  播放列表

#import <UIKit/UIKit.h>

@class FileManagerPlayerListView;
@protocol FileManagerPlayerListViewDelegete <NSObject>
@optional
- (void)managerView:(FileManagerPlayerListView *)managerView didselectedModel:(JHFile *)file;

@end

@interface FileManagerPlayerListView : UIView
@property (strong, nonatomic) JHFile *currentFile;
@property (weak, nonatomic) id<FileManagerPlayerListViewDelegete> delegate;
- (void)scrollToCurrentFile;
@end
