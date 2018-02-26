//
//  DDPDanmakuFilterViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/30.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

@interface DDPDanmakuFilterViewController : DDPBaseViewController
@property (copy, nonatomic) void(^updateFilterCallBack)(void);
@end
