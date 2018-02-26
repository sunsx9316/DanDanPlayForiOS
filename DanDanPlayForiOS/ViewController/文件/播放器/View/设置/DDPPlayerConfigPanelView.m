//
//  DDPPlayerConfigPanelView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerConfigPanelView.h"
#import <WMMenuView.h>
#import "DDPPlayerDanmakuControlView.h"
#import "DDPPlayerVideoControlView.h"
#import "DDPFileManagerPlayerListView.h"
#import "DDPSMBVideoModel.h"

//#import "PickerFileViewController.h"

@interface DDPPlayerConfigPanelView ()<WMMenuViewDataSource, WMMenuViewDelegate, DDPFileManagerPlayerListViewDelegete>
@property (strong, nonatomic) WMMenuView *menu;
@property (strong, nonatomic) DDPFileManagerPlayerListView *listView;
@property (strong, nonatomic) DDPPlayerDanmakuControlView *danmakuControlView;
@property (strong, nonatomic) DDPPlayerVideoControlView *playerControlView;
@end

@implementation DDPPlayerConfigPanelView
{
    UIView *_currentView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        _show = YES;
        
        [self.menu mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(40);
        }];
        
        [self addSubview:self.listView];
        [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.menu.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
        }];
        
        _currentView = self.listView;
    }
    return self;
}

- (void)showWithAnimate:(BOOL)flag {
    if (self.superview && _show == NO) {
        _show = YES;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.mas_equalTo(0);
            make.width.mas_equalTo(self.superview.mas_width).multipliedBy(CONFIG_VIEW_WIDTH_RATE);
        }];
        
        if (flag) {
            [self animate:^{
                [self layoutIfNeeded];
                [self.listView scrollToCurrentFile];
            } completion:nil];
        }
        else {
            [self.listView scrollToCurrentFile];
        }
    }
}

- (void)dismissWithAnimate:(BOOL)flag {
    if (self.superview && _show) {
        _show = NO;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.left.equalTo(self.superview.mas_right);
            make.width.mas_equalTo(self.superview.mas_width).multipliedBy(CONFIG_VIEW_WIDTH_RATE);
        }];
        
        if (flag) {
            [self animate:^{
                [self layoutIfNeeded];
            } completion:nil];
        }
    }
}

#pragma mark - 私有方法
- (void)animate:(dispatch_block_t)animateBlock completion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:animateBlock completion:completion];
}

#pragma mark - WMMenuViewDelegate
- (void)menuView:(WMMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    
    if (currentIndex == index) return;
    
    [_currentView removeFromSuperview];
    
    if (index == 0) {
        _currentView = self.listView;
    }
    else if (index == 1) {
        _currentView = self.danmakuControlView;
    }
    else if (index == 2) {
        _currentView = self.playerControlView;
    }
    
    [self addSubview:_currentView];
    [_currentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.menu.mas_bottom);
        make.left.right.bottom.mas_equalTo(0);
    }];
}


- (CGFloat)menuView:(WMMenuView *)menu titleSizeForState:(WMMenuItemState)state atIndex:(NSInteger)index {
    return [UIFont ddp_normalSizeFont].pointSize;
}

- (UIColor *)menuView:(WMMenuView *)menu titleColorForState:(WMMenuItemState)state atIndex:(NSInteger)index {
    if (state == WMMenuItemStateNormal) {
        return [UIColor whiteColor];
    }
    return [UIColor ddp_mainColor];
}

- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    NSString *str = [self menuView:menu titleAtIndex:index];
    return [str sizeForFont:[UIFont ddp_normalSizeFont] size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping].width + 20;
}

#pragma mark - WMMenuViewDataSource
- (NSInteger)numbersOfTitlesInMenuView:(WMMenuView *)menu {
    return 3;
}

- (NSString *)menuView:(WMMenuView *)menu titleAtIndex:(NSInteger)index {
    if (index == 0) {
        return @"播放列表";
    }
    else if (index == 1) {
        return @"弹幕";
    }
    return @"播放器";
}

#pragma mark - DDPFileManagerPlayerListViewDelegete
- (void)managerView:(DDPFileManagerPlayerListView *)managerView didselectedModel:(DDPFile *)file {
    if ([self.delegate respondsToSelector:@selector(playerConfigPanelView:didSelectedModel:)]) {
        [self.delegate playerConfigPanelView:self didSelectedModel:file.videoModel];
    }
}

#pragma mark - 懒加载
- (WMMenuView *)menu {
    if (_menu == nil) {
        _menu = [[WMMenuView alloc] initWithFrame:CGRectMake(0, 0, self.width, 40)];
        _menu.dataSource = self;
        _menu.delegate = self;
        _menu.style = WMMenuViewStyleLine;
        _menu.speedFactor = 5;
        [self addSubview:_menu];
    }
    return _menu;
}

- (DDPFileManagerPlayerListView *)listView {
    if (_listView == nil) {
        _listView = [[DDPFileManagerPlayerListView alloc] init];
        _listView.delegate = self;
        _listView.currentFile = [DDPCacheManager shareCacheManager].currentPlayVideoModel.file.parentFile;
    }
    return _listView;
}

- (DDPPlayerDanmakuControlView *)danmakuControlView {
    if (_danmakuControlView == nil) {
        _danmakuControlView = [[DDPPlayerDanmakuControlView alloc] init];
        @weakify(self)
        [_danmakuControlView setTouchStepperCallBack:^(CGFloat value) {
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelView:didTouchStepper:)]) {
                [self.delegate playerConfigPanelView:self didTouchStepper:value];
            }
        }];
        
        [_danmakuControlView setTouchSelectedDanmakuCellCallBack:^{
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelViewDidTouchSelectedDanmakuCell)]) {
                [self.delegate playerConfigPanelViewDidTouchSelectedDanmakuCell];
            }
        }];
        
        [_danmakuControlView setTouchMatchVideoCellCallBack:^{
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelViewDidTouchMatchCell)]) {
                [self.delegate playerConfigPanelViewDidTouchMatchCell];
            }
        }];
        
        _danmakuControlView.touchFilterDanmakuCellCallBack = ^{
            @strongify(self)
            if (!self) return;
            
            if ([self.delegate respondsToSelector:@selector(playerConfigPanelViewDidTouchFilterCell)]) {
                [self.delegate playerConfigPanelViewDidTouchFilterCell];
            }
        };
    }
    return _danmakuControlView;
}

- (DDPPlayerVideoControlView *)playerControlView {
    if (_playerControlView == nil) {
        _playerControlView = [[DDPPlayerVideoControlView alloc] init];
    }
    return _playerControlView;
}

@end
