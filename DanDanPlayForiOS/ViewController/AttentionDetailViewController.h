//
//  AttentionDetailViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseViewController.h"

@interface AttentionDetailViewController : BaseViewController
@property (strong, nonatomic) JHFavorite *model;
@property (copy, nonatomic) void(^attentionCallBack)(JHFavorite *model);
@end
