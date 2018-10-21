//
//  DDPPlayerFileManagerPlayerListViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class DDPFileManagerPlayerListView;
@interface DDPPlayerFileManagerPlayerListViewController : DDPBaseViewController

@property (strong, nonatomic, readonly) DDPFileManagerPlayerListView *listView;

@property (copy, nonatomic) void(^_Nullable didSelectedVideoModelCallBack)(DDPVideoModel * _Nullable model);

@end

NS_ASSUME_NONNULL_END
