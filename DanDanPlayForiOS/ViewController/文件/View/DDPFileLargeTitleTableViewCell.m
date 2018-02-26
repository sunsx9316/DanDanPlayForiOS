//
//  DDPFileLargeTitleTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileLargeTitleTableViewCell.h"

@implementation DDPFileLargeTitleTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_offset(0);
            make.left.mas_offset(10);
        }];
        
        [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_offset(-10);
        }];
    }
    return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.touchTitleCallBack) {
        self.touchTitleCallBack(self);
    }
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_blodLargeSizeFont];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)arrowImgView {
    if (_arrowImgView == nil) {
        _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file_header_arrow"]];
        [self.contentView addSubview:_arrowImgView];
    }
    return _arrowImgView;
}

@end
