//
//  HomePageBangumiProgressTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  追番进度

#import <UIKit/UIKit.h>


@interface HomePageBangumiProgressTableViewCell : UITableViewCell
@property (strong, nonatomic) DDPBangumiQueueIntroCollection *collection;
@property (copy, nonatomic) void(^didSelectedBangumiCallBack)(DDPBangumiQueueIntro *model);
@end
