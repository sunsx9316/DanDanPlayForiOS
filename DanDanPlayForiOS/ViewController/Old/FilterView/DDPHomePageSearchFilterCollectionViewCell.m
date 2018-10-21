//
//  DDPHomePageSearchFilterCollectionViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/21.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPHomePageSearchFilterCollectionViewCell.h"

@implementation DDPHomePageSearchFilterCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleButton.titleLabel.font = [UIFont ddp_normalSizeFont];
    [self.titleButton setImage:[[UIImage imageNamed:@"filter_arrow_down"] yy_imageByTintColor:[UIColor ddp_mainColor]] forState:UIControlStateNormal];
    [self.titleButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
    self.lineView.backgroundColor = DDPRGBColor(230, 230, 230);
}

@end
