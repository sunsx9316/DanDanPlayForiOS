//
//  DDPAttentionListTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseTableViewCell.h"
#import "DDPEdgeLabel.h"

@interface DDPAttentionListTableViewCell : DDPBaseTableViewCell
@property (strong, nonatomic) DDPFavorite *model;
@property (strong, nonatomic) DDPBangumiQueueIntro *infoModel;
@end
