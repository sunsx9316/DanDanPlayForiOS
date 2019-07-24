//
//  DDPOtherSettingSwitchTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseTableViewCell.h"

@interface DDPOtherSettingSwitchTableViewCell : DDPBaseTableViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *detailLabel;
@property (strong, nonatomic) UISwitch *aSwitch;
@property (copy, nonatomic) void(^touchSwitchCallBack)(UISwitch *aSwitch);
@end
