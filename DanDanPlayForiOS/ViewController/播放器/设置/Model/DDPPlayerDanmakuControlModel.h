//
//  DDPPlayerDanmakuControlModel.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/6.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@class DDPPlayerControlHeaderView;
@interface DDPPlayerDanmakuControlModel : DDPBase

/**
 重用标识
 */
@property (copy, nonatomic) NSString *reuseIdentifier;

/**
 自定义参数 用于存储头视图属性
 */
@property (strong, nonatomic) NSDictionary <NSString *, id>*headerDic;
@property (copy, nonatomic) void(^didSelectedRowCallBack)(void);
@property (copy, nonatomic) void(^dequeueReuseCellCallBack)(__kindof UITableViewCell *cell);
@property (copy, nonatomic) void(^dequeueReuseHeaderCallBack)(DDPPlayerControlHeaderView *view);
@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) CGFloat headerHeight;

@end
