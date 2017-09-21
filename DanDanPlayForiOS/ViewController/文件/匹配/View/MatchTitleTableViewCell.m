//
//  MatchTitleTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "MatchTitleTableViewCell.h"

@implementation MatchTitleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_offset(10);
            make.right.equalTo(self.arrowImgView.mas_left).mas_offset(-10);
        }];
        
        [self.arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_offset(-10);
            make.centerY.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)expandArrow:(BOOL)expand animate:(BOOL)animate {
    if (animate) {
        if (expand) {
            [UIView animateWithDuration:0.38 animations:^{
                self.arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }
        else {
            [UIView animateWithDuration:0.38 animations:^{
                self.arrowImgView.transform = CGAffineTransformIdentity;
            }];
        }
    }
    else {
        if (expand) {
            self.arrowImgView.transform = CGAffineTransformMakeRotation(M_PI);
        }
        else {
            self.arrowImgView.transform = CGAffineTransformIdentity;
        }
    }
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIImageView *)arrowImgView {
    if (_arrowImgView == nil) {
        _arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_arrow_down"]];
        [_arrowImgView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_arrowImgView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_arrowImgView];
    }
    return _arrowImgView;
}

@end
