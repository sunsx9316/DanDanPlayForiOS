//
//  HomePageItemTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ITEM_CELL_HEIGHT (80 + jh_isPad() * 30)

@interface HomePageItemTableViewCell : UITableViewCell
@property (strong, nonatomic) JHHomeBangumi *model;
@property (copy, nonatomic) void(^selectedItemCallBack)(JHHomeBangumiSubtitleGroup *model);
@property (copy, nonatomic) void(^touchLikeCallBack)(JHHomeBangumi *model);
@end
