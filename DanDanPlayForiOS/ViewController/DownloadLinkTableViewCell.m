//
//  DownloadLinkTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DownloadLinkTableViewCell.h"

@interface DownloadLinkTableViewCell ()
@property (strong, nonatomic, readwrite) JHLinkDownloadTask *task;
@end

@implementation DownloadLinkTableViewCell
@synthesize task = _task;

- (void)setTask:(id)task animate:(BOOL)animate {
    _task = task;
    [self updateDataSourceWithAnimate:animate];
}

- (void)updateDataSourceWithAnimate:(BOOL)flag {
    float progress = _task.progress;
    if (isnan(progress)) {
        progress = 0;
    }
    
    NSString *progressStr = [NSString stringWithFormat:@"%.1f%%", progress * 100];
    NSString *name = _task.name;
    
    self.progressLabel.text = progressStr;
    self.progressBGLabel.text = progressStr;
    self.titleLabel.text = name;
    self.titleBGLabel.text = name;
    
    if (flag) {
        self.progressLayer.frame = CGRectMake(0, 0, progress * self.width, self.height);
        if (_task.state == JHLinkDownloadTaskStateDownloading || _task.state == JHLinkDownloadTaskStateMaskTorrent) {
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
        if (_task.state == JHLinkDownloadTaskStateDownloading || _task.state == JHLinkDownloadTaskStateMaskTorrent) {
            self.progressView.backgroundColor = MAIN_COLOR;
        }
        else {
            self.progressView.backgroundColor = [UIColor darkGrayColor];
        }
        [CATransaction commit];
    }
}

@end
