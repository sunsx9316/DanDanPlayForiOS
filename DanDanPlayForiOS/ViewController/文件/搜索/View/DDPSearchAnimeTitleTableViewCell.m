//
//  DDPSearchAnimeTitleTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSearchAnimeTitleTableViewCell.h"

@implementation DDPSearchAnimeTitleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor ddp_veryLightGrayColor];
        
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
        }];
    }
    return self;
}

@end
