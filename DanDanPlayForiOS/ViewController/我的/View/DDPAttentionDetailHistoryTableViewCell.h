//
//  DDPAttentionDetailHistoryTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseTableViewCell.h"

@class DDPLinkFile;
@interface DDPAttentionDetailHistoryTableViewCell : DDPBaseTableViewCell
@property (strong, nonatomic) DDPEpisode *model;
@property (copy, nonatomic) void(^touchPlayButtonCallBack)(DDPLinkFile *file);
@property (copy, nonatomic) void(^touchTagButtonCallBack)(DDPLinkFile *file);
@end
