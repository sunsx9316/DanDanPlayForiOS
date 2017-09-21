//
//  SettingTitleTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SettingTitleTableViewCell.h"

@implementation SettingTitleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.left.mas_offset(10);
            make.bottom.mas_offset(-10);
            make.right.equalTo(self.detailLabel.mas_left).mas_offset(-10);
        }];
        
        [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.right.equalTo(self.arrowImgView.mas_left).mas_offset(-10);
            make.bottom.mas_offset(-10);
        }];
        
        [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_offset(-10);
        }];
        
    }
    return self;
}

#pragma mark - 懒加载

- (UIImageView *)arrowImgView {
    if (_arrowImgView == nil) {
        _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_right_arrow"]];
        [_arrowImgView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_arrowImgView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_arrowImgView];
    }
    return _arrowImgView;
}

@end
