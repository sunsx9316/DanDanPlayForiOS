//
//  DownloadTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DownloadTableViewCell.h"
#import "TOSMBSessionDownloadTask+Tools.h"

@interface DownloadTableViewCell ()
@property (strong, nonatomic, readwrite) TOSMBSessionDownloadTask *task;
@end

@implementation DownloadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.titleBGLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.progressBGLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.bottom.mas_offset(-10);
        }];
        
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        self.progressView.layer.mask = self.progressLayer;
    }
    return self;
}

- (void)setTask:(TOSMBSessionDownloadTask *)task animate:(BOOL)animate {
    _task = task;
    [self updateDataSourceWithAnimate:animate];
}

- (void)updateDataSourceWithAnimate:(BOOL)flag {
    float progress = _task.progress;
    if (isnan(progress)) {
        progress = 0;
    }
    
    NSString *progressStr = [NSString stringWithFormat:@"%.1f%%", progress * 100];
    NSString *name = _task.sourceFilePath.lastPathComponent;
    
    self.progressLabel.text = progressStr;
    self.progressBGLabel.text = progressStr;
    self.titleLabel.text = name;
    self.titleBGLabel.text = name;
    
    if (flag) {
        self.progressLayer.frame = CGRectMake(0, 0, progress * self.width, self.height);
        if (_task.state == TOSMBSessionDownloadTaskStateRunning) {
            self.progressView.layer.backgroundColor = MAIN_COLOR.CGColor;
        }
        else {
            self.progressView.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
        }
    }
    else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.progressLayer.frame = CGRectMake(0, 0, progress * self.width, self.height);
        if (_task.state == TOSMBSessionDownloadTaskStateRunning) {
            self.progressView.backgroundColor = MAIN_COLOR;
        }
        else {
            self.progressView.backgroundColor = [UIColor darkGrayColor];
        }
        [CATransaction commit];
    }
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (UILabel *)progressLabel {
    if (_progressLabel == nil) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = SMALL_SIZE_FONT;
        _progressLabel.textColor = [UIColor whiteColor];
    }
    return _progressLabel;
}

- (UILabel *)titleBGLabel {
    if (_titleBGLabel == nil) {
        _titleBGLabel = [[UILabel alloc] init];
        _titleBGLabel.font = NORMAL_SIZE_FONT;
        _titleBGLabel.textColor = [UIColor blackColor];
        _titleBGLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_titleBGLabel];
    }
    return _titleBGLabel;
}

- (UILabel *)progressBGLabel {
    if (_progressBGLabel == nil) {
        _progressBGLabel = [[UILabel alloc] init];
        _progressBGLabel.font = SMALL_SIZE_FONT;
        _progressBGLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_progressBGLabel];
    }
    return _progressBGLabel;
}

- (CALayer *)progressLayer {
    if (_progressLayer == nil) {
        _progressLayer = [CALayer layer];
        _progressLayer.backgroundColor = [UIColor whiteColor].CGColor;
    }
    return _progressLayer;
}

- (UIView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = MAIN_COLOR;
        [self.contentView addSubview:_progressView];
        
        [_progressView addSubview:self.progressLabel];
        [_progressView addSubview:self.titleLabel];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.bottom.mas_offset(-10);
        }];
    }
    return _progressView;
}

@end
