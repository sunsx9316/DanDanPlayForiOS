//
//  DDPAttentionDetailHistoryTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDPLinkFile;
@interface DDPAttentionDetailHistoryTableViewCell : UITableViewCell
@property (strong, nonatomic) DDPEpisode *model;
@property (copy, nonatomic) void(^touchPlayButtonCallBack)(DDPLinkFile *file);
@end
