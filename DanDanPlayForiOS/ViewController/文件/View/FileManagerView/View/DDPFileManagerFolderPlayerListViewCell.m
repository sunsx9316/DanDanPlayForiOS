//
//  DDPFileManagerFolderPlayerListViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileManagerFolderPlayerListViewCell.h"

@interface DDPFileManagerFolderPlayerListViewCell ()

@end

@implementation DDPFileManagerFolderPlayerListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10, 10));
        }];
    }
    return self;
}

- (void)setModel:(DDPVideoModel *)model {
    _model = model;
    self.titleLabel.text = _model.name;
    if ([_model isEqual:[DDPCacheManager shareCacheManager].currentPlayVideoModel]) {
        self.titleLabel.textColor = [UIColor ddp_mainColor];
    }
    else {
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
