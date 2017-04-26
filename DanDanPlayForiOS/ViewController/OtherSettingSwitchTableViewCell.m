//
//  OtherSettingSwitchTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "OtherSettingSwitchTableViewCell.h"

@interface OtherSettingSwitchTableViewCell ()

@end

@implementation OtherSettingSwitchTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.font = NORMAL_SIZE_FONT;
    self.detailLabel.font = SMALL_SIZE_FONT;
}

- (IBAction)touchSwitch:(UISwitch *)sender {
    if (self.touchSwitchCallBack) {
        self.touchSwitchCallBack();
    }
}


@end
