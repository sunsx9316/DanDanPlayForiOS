//
//  DDPAttentionDetailViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

@interface DDPAttentionDetailViewController : DDPBaseViewController
@property (assign, nonatomic) NSUInteger animateId;
@property (assign, nonatomic) BOOL isOnAir;
@property (copy, nonatomic) void(^attentionCallBack)(NSUInteger animateId);
@end
