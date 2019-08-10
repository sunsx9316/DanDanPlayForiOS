//
//  DDPAttentionDetailTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseTableViewCell.h"

#if DDPAPPTYPEISMAC
#define DETAIL_CELL_HEIGHT (210 + ddp_isPad() * 30)
#else
#define DETAIL_CELL_HEIGHT (110 + ddp_isPad() * 30)
#endif

@interface DDPAttentionDetailTableViewCell : DDPBaseTableViewCell
@property (strong, nonatomic) DDPPlayHistory *model;
@property (copy, nonatomic) void(^touchSearchButtonCallBack)(DDPPlayHistory *model);
@property (copy, nonatomic) void(^touchLikeButtonCallBack)(DDPPlayHistory *model);
@end
