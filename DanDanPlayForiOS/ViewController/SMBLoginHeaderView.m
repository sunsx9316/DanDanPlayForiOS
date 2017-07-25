//
//  SMBLoginHeaderView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBLoginHeaderView.h"

@interface SMBLoginHeaderView ()
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation SMBLoginHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(10);
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = SMALL_SIZE_FONT;
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.text = @"登录历史";
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
