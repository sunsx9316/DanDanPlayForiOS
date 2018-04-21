//
//  DDPHomeMoreHeaderView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPTextHeaderView.h"

@interface DDPHomeMoreHeaderView : DDPTextHeaderView
@property (strong, nonatomic) UIImageView *moreImgView;
@property (strong, nonatomic) UILabel *detailLabel;

@property (copy, nonatomic) void(^touchCallBack)(void);
@end
