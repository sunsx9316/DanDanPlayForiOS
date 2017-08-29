//
//  PlayerSelectedColorViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseViewController.h"

@interface PlayerSelectedColorViewController : BaseViewController
@property (copy, nonatomic) void(^sendDanmakuCallBack)(UIColor *color, JHDanmakuMode mode, NSString *text);
@end
