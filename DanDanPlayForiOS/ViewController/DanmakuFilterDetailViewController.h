//
//  DanmakuFilterDetailViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseViewController.h"

@interface DanmakuFilterDetailViewController : BaseViewController
@property (strong, nonatomic) JHFilter *model;
@property (copy, nonatomic) void(^addFilterCallback)(JHFilter *model);
@end
