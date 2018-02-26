//
//  HomePageSearchTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageSearchTableViewCell : UITableViewCell
@property (strong, nonatomic) DDPDMHYSearch *model;
@property (copy, nonatomic) void(^touchSubGroupCallBack)(DDPDMHYSearch *model);
@end
