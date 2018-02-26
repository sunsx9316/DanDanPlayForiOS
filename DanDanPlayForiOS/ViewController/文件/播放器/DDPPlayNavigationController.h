//
//  DDPPlayNavigationController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPPlayerViewController.h"

@interface DDPPlayNavigationController : UINavigationController
- (instancetype)initWithModel:(DDPVideoModel *)model;
@end
