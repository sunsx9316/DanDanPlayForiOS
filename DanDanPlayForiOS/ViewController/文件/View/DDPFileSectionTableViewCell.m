//
//  DDPFileSectionTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileSectionTableViewCell.h"

@implementation DDPFileSectionTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_offset(15);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImgView.mas_right).mas_offset(10);
            make.centerY.equalTo(self.iconImgView);
        }];
        
//        [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.right.mas_offset(-10);
//            make.centerY.equalTo(self.iconImgView);
//        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] init];
        [self.contentView addSubview:_iconImgView];
    }
    return _iconImgView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

//- (UIImageView *)arrowImgView {
//    if (_arrowImgView == nil) {
//        _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_right_arrow"]];
//        [self.contentView addSubview:_arrowImgView];
//    }
//    return _arrowImgView;
//}

@end
