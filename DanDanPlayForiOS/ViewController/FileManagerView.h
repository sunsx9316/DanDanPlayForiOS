//
//  FileManagerView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  文件管理视图

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, FileManagerViewType) {
    FileManagerViewTypeLong,
    FileManagerViewTypeShort,
    FileManagerViewTypePlayerList,
};

@class FileManagerView;
@protocol FileManagerViewDelegate <NSObject>
@optional
- (void)managerView:(FileManagerView *)managerView didselectedModel:(JHFile *)file;

@end

@interface FileManagerView : UIView
@property (copy, nonatomic) NSString *searchKey;
@property (strong, nonatomic) JHFile *currentFile;
@property (assign, nonatomic) FileManagerViewType type;
@property (weak, nonatomic) id<FileManagerViewDelegate>delegate;
- (void)reloadDataWithAnimate:(BOOL)flag;
@end
