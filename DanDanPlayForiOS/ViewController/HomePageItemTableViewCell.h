//
//  HomePageItemTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageItemTableViewCell : UITableViewCell
@property (strong, nonatomic) JHBangumi *model;
@property (copy, nonatomic) void(^selectedItemCallBack)(JHBangumiGroup *model);
@property (copy, nonatomic) void(^touchLikeCallBack)(JHBangumi *model);
@end
