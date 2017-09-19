//
//  AttentionDetailViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseViewController.h"

@interface AttentionDetailViewController : BaseViewController
@property (assign, nonatomic) NSUInteger animateId;
@property (assign, nonatomic) BOOL isOnAir;
//@property (strong, nonatomic) JHFavorite *model;
@property (copy, nonatomic) void(^attentionCallBack)(NSUInteger animateId);
@end
