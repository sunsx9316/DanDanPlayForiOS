//
//  SMBLoginTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBLoginTableViewCell.h"

@interface SMBLoginTableViewCell ()
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation SMBLoginTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(5, 10, 0, 10));
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.backgroundColor = MAIN_COLOR;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.layer.cornerRadius = 6;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"连接";
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
