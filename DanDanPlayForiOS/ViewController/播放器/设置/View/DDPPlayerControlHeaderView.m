//
//  DDPPlayerControlHeaderView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerControlHeaderView.h"

@implementation DDPPlayerControlHeaderView
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = DDPRGBAColor(0, 0, 0, 0.1);
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.centerY.mas_equalTo(0);
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_smallSizeFont];
        _titleLabel.textColor = DDPRGBColor(220, 220, 220);
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
