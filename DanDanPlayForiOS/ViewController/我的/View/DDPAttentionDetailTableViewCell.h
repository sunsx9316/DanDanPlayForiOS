//
//  DDPAttentionDetailTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DETAIL_CELL_HEIGHT (110 + ddp_isPad() * 30)

@interface DDPAttentionDetailTableViewCell : UITableViewCell
@property (strong, nonatomic) DDPPlayHistory *model;
@property (copy, nonatomic) void(^touchSearchButtonCallBack)(DDPPlayHistory *model);
@end
