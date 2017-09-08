//
//  HomePageSearchTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomePageSearchTableViewCell : UITableViewCell
@property (strong, nonatomic) JHDMHYSearch *model;
@property (copy, nonatomic) void(^touchSubGroupCallBack)(JHDMHYSearch *model);
@end
