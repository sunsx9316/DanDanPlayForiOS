//
//  FileManagerFolderCollectionViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/28.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerFolderLongViewCell.h"

@interface FileManagerFolderLongViewCell ()

@end

@implementation FileManagerFolderLongViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc] init];
        
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_offset(10);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImgView.mas_right).mas_offset(10);
//            make.centerY.mas_equalTo(0);
            make.top.mas_offset(30);
            make.bottom.mas_offset(-25);
            make.right.mas_offset(-10);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.iconImgView);
//            make.centerY.equalTo(self.iconImgView).mas_offset(3);
//            make.centerY.mas_equalTo(0);
//            make.right.mas_offset(-25);
//            make.left.equalTo(self.titleLabel.mas_right).mas_offset(10);
            make.edges.equalTo(self.iconImgView).mas_offset(UIEdgeInsetsMake(5, 0, 0, 0));
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if(_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = VERY_SMALL_SIZE_FONT;
        _detailLabel.numberOfLines = 2;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.textColor = [UIColor whiteColor];
//        [_detailLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//        [_detailLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_local_file_folder"]];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFit;
        [_iconImgView setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_iconImgView setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self.contentView addSubview:_iconImgView];
    }
    return _iconImgView;
}

@end
