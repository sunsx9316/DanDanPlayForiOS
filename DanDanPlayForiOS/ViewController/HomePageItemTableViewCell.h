//
//  HomePageItemTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ITEM_CELL_HEIGHT (80 + ddp_isPad() * 30)

@interface HomePageItemTableViewCell : UITableViewCell
@property (strong, nonatomic) DDPHomeBangumi *model;
@property (copy, nonatomic) void(^selectedItemCallBack)(DDPHomeBangumiSubtitleGroup *model);
@property (copy, nonatomic) void(^touchLikeCallBack)(DDPHomeBangumi *model);
@end
