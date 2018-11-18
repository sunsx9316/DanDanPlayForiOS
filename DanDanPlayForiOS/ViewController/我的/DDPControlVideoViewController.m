//
//  DDPControlVideoViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/8/5.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPControlVideoViewController.h"
#import "DDPQRScannerViewController.h"
#import "DDPLinkNetManagerOperation.h"
#import "DDPMediaPlayer.h"
#import "DDPTransparentNavigationBar.h"

@interface DDPControlVideoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIView *gestureView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) DDPLibrary *currentVideoModel;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DDPControlVideoViewController
{
    BOOL _touchSliderDown;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"遥控器";
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.currentVideoModel = nil;
    self.slider.tintColor = [UIColor ddp_mainColor];
    
    if ([DDPCacheManager shareCacheManager].linkInfo == nil) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"并没有连接到电脑 是否扫码连接" preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self jumpToLinkVC];
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:vc animated:true completion:nil];
    }
    else {
        [self firstGetCurrentVideo];
    }
}

- (Class)ddp_navigationBarClass {
    return [DDPTransparentNavigationBar class];
}

- (IBAction)touchPlayButton:(UIButton *)sender {
    if ([self ipAddress].length == 0) {
        return;
    }
    
    sender.selected = !sender.isSelected;
    
    [DDPLinkNetManagerOperation linkControlWithIpAdress:[self ipAddress] method:sender.isSelected ? JHControlVideoMethodPause : JHControlVideoMethodPlay completionHandler:nil];
}

- (IBAction)touchNextButton:(UIButton *)sender {
    [DDPLinkNetManagerOperation linkControlWithIpAdress:[self ipAddress] method:JHControlVideoMethodNext completionHandler:nil];
}

- (IBAction)touchPreButton:(UIButton *)sender {
    [DDPLinkNetManagerOperation linkControlWithIpAdress:[self ipAddress] method:JHControlVideoMethodNext completionHandler:nil];
}

- (IBAction)touchDownSlider:(UISlider *)sender {
    _touchSliderDown = true;
}


- (IBAction)touchUpSlider:(UISlider *)sender {
    _touchSliderDown = false;
    
    
    NSUInteger time = self.currentVideoModel.duration;
    if (time == 0) {
        return;
    }
    
    NSUInteger jump = time * 1.0 * sender.value;
    
    [DDPLinkNetManagerOperation linkChangeWithIpAdress:[self ipAddress] time:jump completionHandler:^(NSError *error) {
        
    }];
}


- (IBAction)touchSlider:(UISlider *)sender {
    if (_touchSliderDown) {
        [self updateTimeWithProgress:sender.value];
    }
}


#pragma mark - 私有方法
- (void)jumpToLinkVC {
    let vc = [[DDPQRScannerViewController alloc] init];
    @weakify(self)
    vc.linkSuccessCallBack = ^(DDPLinkInfo *info) {
        @strongify(self)
        if (!self) return;
        
        if (info != nil) {
            [self.navigationController popViewControllerAnimated:true];
            [self firstGetCurrentVideo];
        }
    };
    
    [self.navigationController pushViewController:vc animated:true];
}

- (void)getCurrentVideoInfoWithCompletion:(void(^)(NSError *error))completion {
    @weakify(self)
    [DDPLinkNetManagerOperation linkGetVideoInfoWithIpAdress:[self ipAddress] completionHandler:^(DDPLibrary *model, NSError *error) {
        @strongify(self)
        if (!self) return;
        
        if (error == nil) {
            self.currentVideoModel = model;
        }
        
        if (completion) {
            completion(error);
        }
    }];
    
}

- (void)firstGetCurrentVideo {
    [self.view showLoading];
    @weakify(self)
    [self getCurrentVideoInfoWithCompletion:^(NSError *error) {
        @strongify(self)
        if (!self) return;
        
        [self.view hideLoading];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            if (!self) return;
            
            [self getCurrentVideoInfoWithCompletion:nil];
        } repeats:true];
    }];
}

- (NSString *)ipAddress {
    return [DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress;
}

- (void)setCurrentVideoModel:(DDPLibrary *)currentVideoModel {
    _currentVideoModel = currentVideoModel;
    
    self.mainTitleLabel.text = _currentVideoModel.animeTitle;
    self.subtitleLabel.text = _currentVideoModel.episodeTitle;
    self.slider.enabled = _currentVideoModel.seekable;
    
    if (_currentVideoModel.playing) {
        self.playButton.selected = !_currentVideoModel.playing.boolValue;
    }
    
    if (_touchSliderDown == false) {
        self.slider.value = _currentVideoModel.position;
        [self updateTimeWithProgress:_currentVideoModel.position];
    }
}

- (void)updateTimeWithProgress:(CGFloat)progress {
    NSInteger duration = _currentVideoModel.duration * 1.0 / 1000.0;
    NSInteger currentTime = duration * progress;
    
    NSString *timeStr = [NSString stringWithFormat:@"%@ / %@", ddp_mediaFormatterTime(currentTime), ddp_mediaFormatterTime(duration)];
    self.timeLabel.text = timeStr;
}


@end
