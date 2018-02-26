//
//  DDPAttentionListViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  关注

#import "DDPBaseViewController.h"


/**
 列表类型

 - DDPAnimateListTypeAttention: 关注列表
 - DDPAnimateListTypeProgress: 追番进度
 */
typedef NS_ENUM(NSUInteger, DDPAnimateListType) {
    DDPAnimateListTypeAttention,
    DDPAnimateListTypeProgress
};

@interface DDPAttentionListViewController : DDPBaseViewController
@property (assign, nonatomic) DDPAnimateListType type;
@end
