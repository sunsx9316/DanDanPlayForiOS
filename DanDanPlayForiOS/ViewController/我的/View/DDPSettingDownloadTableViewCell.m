//
//  DDPSettingDownloadTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSettingDownloadTableViewCell.h"

@interface DDPSettingDownloadTableViewCell ()
@property (strong, nonatomic) UILabel *countLabel;
@end

@implementation DDPSettingDownloadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.arrowImgView).mas_equalTo(0);
            make.right.equalTo(self.arrowImgView.mas_left).mas_offset(-10);
            float width = 20 + ddp_isPad() * 10;
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
        self.countLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_downLoadCount];
    }
}

#pragma mark - 懒加载

- (UILabel *)countLabel {
    if (_countLabel == nil) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = DDPRGBColor(226, 74, 70);
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont ddp_verySmallSizeFont];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:_countLabel];
    }
    return _countLabel;
}

@end
