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
//@property (strong, nonatomic) id<DDPDownloadTaskProtocol> task;
//@property (strong, nonatomic, readwrite) TOSMBSessionDownloadTask *task;
@end

@implementation DDPDownloadTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.progressView];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.bottom.mas_offset(-10);
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
    if (_task.ddp_state == DDPDownloadTaskStateRunning) {
        self.progressView.backgroundColor = [UIColor ddp_mainColor];
    }
    else {
        self.progressView.backgroundColor = [UIColor darkGrayColor];
    }
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)progressLabel {
    if (_progressLabel == nil) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont ddp_smallSizeFont];
        _progressLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_progressLabel];
    }
    return _progressLabel;
}

//- (UILabel *)titleBGLabel {
//    if (_titleBGLabel == nil) {
//        _titleBGLabel = [[UILabel alloc] init];
//        _titleBGLabel.font = [UIFont ddp_normalSizeFont];
//        _titleBGLabel.textColor = [UIColor blackColor];
//        _titleBGLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
//        [self.contentView addSubview:_titleBGLabel];
//    }
//    return _titleBGLabel;
//}
//
//- (UILabel *)progressBGLabel {
//    if (_progressBGLabel == nil) {
//        _progressBGLabel = [[UILabel alloc] init];
//        _progressBGLabel.font = [UIFont ddp_smallSizeFont];
//        _progressBGLabel.textColor = [UIColor blackColor];
//        [self.contentView addSubview:_progressBGLabel];
//    }
//    return _progressBGLabel;
//}

//- (CALayer *)progressLayer {
//    if (_progressLayer == nil) {
//        _progressLayer = [CALayer layer];
//        _progressLayer.backgroundColor = [UIColor whiteColor].CGColor;
//    }
//    return _progressLayer;
//}

- (UIView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = [UIColor ddp_mainColor];
//        [self.contentView addSubview:_progressView];
    }
    return _progressView;
}

@end
