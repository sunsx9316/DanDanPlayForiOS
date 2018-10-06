//
//  DDPPlayerShieldDanmakuCollectionViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/4/16.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPPlayerShieldDanmakuCollectionViewCell.h"

@interface DDPPlayerShieldDanmakuCollectionViewCell ()

@end

@implementation DDPPlayerShieldDanmakuCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.textColor = [UIColor ddp_mainColor];
    self.titleLabel.font = [UIFont ddp_smallSizeFont];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.titleLabel.backgroundColor = [UIColor ddp_mainColor];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor ddp_mainColor];
    }
}

@end
