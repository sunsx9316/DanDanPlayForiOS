//
//  DDPPlayerConfigPanelViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPPlayerConfigPanelViewController.h"
#import "DDPDefaultPageViewController.h"
#import "DDPPlayerDanmakuControlViewController.h"
#import "DDPPlayerVideoControlViewController.h"
#import "DDPPlayerFileManagerPlayerListViewController.h"

@interface DDPPlayerConfigPanelViewController ()<WMPageControllerDelegate, WMPageControllerDataSource, UIDocumentPickerDelegate>
@property (strong, nonatomic) DDPDefaultPageViewController *pageController;
@property (strong, nonatomic) NSArray <NSString *>*dataSources;

@property (strong, nonatomic) UIView *holdView;
@end

@implementation DDPPlayerConfigPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.holdView];
    
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    
    [self.holdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (ddp_appType != DDPAppTypeToMac) {
        self.view.backgroundColor = [UIColor clearColor];
    } else {
        self.title = @"播放器设置";
    }
    self.pageController.view.backgroundColor = DDPRGBAColor(0, 0, 0, 0.8);
    self.pageController.scrollView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (ddp_appType != DDPAppTypeToMac) {
        var frame = self.view.bounds;
        
        CGFloat width = frame.size.width * 0.5;
        
        self.pageController.view.frame = CGRectMake(width, 0, width, frame.size.height);        
    }
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.dataSources.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    let title = self.dataSources[index];
    @weakify(self)
    if ([title isEqualToString:@"播放列表"]) {
        let vc = [[DDPPlayerFileManagerPlayerListViewController alloc] init];
        vc.didSelectedVideoModelCallBack = ^(DDPVideoModel * _Nullable model) {
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelViewController:didSelectedModel:)]) {
                [self.delegate playerConfigPanelViewController:self didSelectedModel:model];
            }
//            [self dismissViewControllerAnimated:true completion:nil];
        };
        return vc;
    }
    
    if ([title isEqualToString:@"弹幕"]) {
        let vc = [[DDPPlayerDanmakuControlViewController alloc] init];
        
        @weakify(self)
        vc.touchStepperCallBack = ^(CGFloat value) {
            @strongify(self)
            if (!self) return;
            
            DDPCacheManager.shareCacheManager.danmakuOffsetTime = value;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelViewController:didTouchStepper:)]) {
                [self.delegate playerConfigPanelViewController:self didTouchStepper:value];
            }
        };
        
        [vc setTouchSelectedDanmakuCellCallBack:^{
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelViewControllerDidTouchSelectedDanmakuCell)]) {
                [self.delegate playerConfigPanelViewControllerDidTouchSelectedDanmakuCell];
            }
            
        }];
        
        [vc setTouchMatchVideoCellCallBack:^{
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelViewControllerDidTouchMatchCell)]) {
                [self.delegate playerConfigPanelViewControllerDidTouchMatchCell];
            }
        }];
        
        vc.touchFilterDanmakuCellCallBack = ^{
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelViewControllerDidTouchFilterCell)]) {
                [self.delegate playerConfigPanelViewControllerDidTouchFilterCell];
            }
        };
        
        vc.touchOtherSettingCellCallBack = ^{
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelViewControllerDidTouchOtherSettingCell)]) {
                [self.delegate playerConfigPanelViewControllerDidTouchOtherSettingCell];
            }
        };
        
        return vc;
    }
    
    let vc = [[DDPPlayerVideoControlViewController alloc] init];
    return vc;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.dataSources[index];
}

#pragma mark - WMPageControllerDelegate
- (CGRect)pageController:(nonnull WMPageController *)pageController preferredFrameForContentView:(nonnull WMScrollView *)contentView {
    let frame = [self pageController:pageController preferredFrameForMenuView:pageController.menuView];
    let y = CGRectGetMaxY(frame);
    return CGRectMake(0, y, frame.size.width, self.view.height - y);
}


- (CGRect)pageController:(nonnull WMPageController *)pageController preferredFrameForMenuView:(nonnull WMMenuView *)menuView {
    CGFloat width = 0;
    if (ddp_appType == DDPAppTypeToMac) {
        width = self.view.width;
    } else {
        width = self.view.width * 0.5;
    }
    return CGRectMake(0, CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame), width, 40);
}

#pragma mark - 懒加载

- (DDPDefaultPageViewController *)pageController {
    if (_pageController == nil) {
        _pageController = [[DDPDefaultPageViewController alloc] init];
        _pageController.delegate = self;
        _pageController.dataSource = self;
        _pageController.scrollEnable = false;
        _pageController.itemMargin = 15;
    }
    return _pageController;
}

- (NSArray<NSString *> *)dataSources {
    if (_dataSources == nil) {
        if (ddp_appType == DDPAppTypeToMac) {
            _dataSources = @[@"弹幕", @"播放器"];
        } else {
            _dataSources = @[@"播放列表", @"弹幕", @"播放器"];
        }
    }
    return _dataSources;
}

- (UIView *)holdView {
    if (_holdView == nil) {
        _holdView = [[UIView alloc] init];
        _holdView.userInteractionEnabled = true;
        @weakify(self)
        [_holdView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            if (self.touchBgViewCallBack) {
                self.touchBgViewCallBack();
            }
        }]];
    }
    return _holdView;
}

@end
