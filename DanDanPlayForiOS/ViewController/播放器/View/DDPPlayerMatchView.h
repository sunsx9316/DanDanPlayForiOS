//
//  DDPPlayerMatchView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/3/10.
//  Copyright © 2018年 JimHuang. All rights reserved.
//  左边弹出来的匹配视图

#import "DDPPlayerNoticeView.h"

@interface DDPPlayerMatchView : DDPPlayerNoticeView
@property (copy, nonatomic) void(^touchMatchButtonCallBack)(void);
@end
