//
//  DDPPlayerSendDanmakuViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

@interface DDPPlayerSendDanmakuViewController : DDPBaseViewController
@property (copy, nonatomic) void(^sendDanmakuCallBack)(UIColor *color, DDPDanmakuMode mode, NSString *text);
@end
