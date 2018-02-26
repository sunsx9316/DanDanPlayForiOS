//
//  DDPPlayerDanmakuControlModel.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/6.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"

@interface DDPPlayerDanmakuControlModel : DDPBase
@property (copy, nonatomic) NSString *initializeClass;
@property (strong, nonatomic) NSDictionary <NSString *, id>*cellDic;
@property (copy, nonatomic) void(^didSelectedRowCallBack)(void);
@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) CGFloat headerHeight;
@property (strong, nonatomic) NSDictionary <NSString *, id>*headerDic;
@end
