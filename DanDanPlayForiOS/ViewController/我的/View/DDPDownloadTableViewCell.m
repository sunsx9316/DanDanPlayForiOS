//
//  DDPDownloadTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDownloadTableViewCell.h"
#import "TOSMBSessionDownloadTask+Tools.h"

@interface DDPDownloadTableViewCell ()
@property (strong, nonatomic) UIView *bottomLineView;
@end

@implementation DDPDownloadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        self.selectedBackgroundView = [[UIView alloc] init];
        
        [self.contentView addSubview:self.progressView];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(10);
            make.bottom.mas_offset(-10);
        }];
        
        [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(1);
        }];
        
    }
    return self;
}

- (void)setTask:(id<DDPDownloadTaskProtocol>)task {
    _task = task;
    
    float progress = _task.ddp_progress;
    if (isnan(progress)) {
        progress = 0;
    }
    
    NSString *progressStr = [NSString stringWithFormat:@"%.1f%%", progress * 100];
    NSString *name = _task.ddp_name;
    
    self.progressLabel.text = progressStr;
    self.titleLabel.text = name;
    
    self.progressView.frame = CGRectMake(0, 0, progress * self.width, self.height);
    if (_task.isDdp_downloading) {
        self.progressView.backgroundColor = DDPRGBColor(254, 103, 35);
    }
    else {
        self.progressView.backgroundColor = [UIColor lightGrayColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectedBackgroundView.backgroundColor = self.contentView.backgroundColor;
}


#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColor = DDPRGBColor(60, 60, 60);
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)progressLabel {
    if (_progressLabel == nil) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont ddp_smallSizeFont];
        _progressLabel.textColor = DDPRGBColor(80, 80, 80);
        [self.contentView addSubview:_progressLabel];
    }
    return _progressLabel;
}

- (UIView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = DDPRGBColor(254, 103, 235);
    }
    return _progressView;
}

- (UIView *)bottomLineView {
    if (_bottomLineView == nil) {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_bottomLineView];
    }
    return _bottomLineView;
}

@end
