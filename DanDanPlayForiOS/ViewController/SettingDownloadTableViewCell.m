//
//  SettingDownloadTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SettingDownloadTableViewCell.h"

@interface SettingDownloadTableViewCell ()
@property (strong, nonatomic) UILabel *countLabel;
@end

@implementation SettingDownloadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.arrowImgView).mas_equalTo(0);
            make.right.equalTo(self.arrowImgView.mas_left).mas_offset(-10);
            float width = 20 + jh_isPad() * 10;
            make.width.height.mas_equalTo(width);
            self.countLabel.layer.cornerRadius = width / 2;
        }];
        
    }
    return self;
}

- (void)setDownLoadCount:(NSUInteger)downLoadCount {
    _downLoadCount = downLoadCount;
    
    self.countLabel.hidden = _downLoadCount == 0;
    
    if (_downLoadCount > 99) {
        self.countLabel.text = @"99+";
    }
    else {
        self.countLabel.text = [NSString stringWithFormat:@"%ld", _downLoadCount];
    }
}

#pragma mark - 懒加载

- (UILabel *)countLabel {
    if (_countLabel == nil) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = RGBCOLOR(226, 74, 70);
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = VERY_SMALL_SIZE_FONT;
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_countLabel];
    }
    return _countLabel;
}

@end
