//
//  PlayerStepTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerStepTableViewCell : UITableViewCell
@property (copy, nonatomic) void(^touchStepperCallBack)(CGFloat value);
@end
