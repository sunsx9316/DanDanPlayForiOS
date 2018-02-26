//
//  HomePageItemCollectionViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageItemCollectionViewCell.h"
#import "DDPEdgeButton.h"

@implementation HomePageItemCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UIButton *)button {
    if (_button == nil) {
        DDPEdgeButton *aButton = [[DDPEdgeButton alloc] init];
        aButton.inset = CGSizeMake(10, 10);
        _button = aButton;
        _button.userInteractionEnabled = NO;
        _button.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_button setBackgroundImage:[UIImage imageNamed:@"home_bangumi_group_bg"] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.contentView addSubview:_button];
    }
    return _button;
}

@end
