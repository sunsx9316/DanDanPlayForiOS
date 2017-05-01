//
//  PlayerConfigPanelView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerConfigPanelView.h"
#import <WMMenuView.h>
//#import "PlayerListView.h"
#import "PlayerDanmakuControlView.h"
#import "PlayerControlView.h"
#import "FileManagerView.h"

@interface PlayerConfigPanelView ()<WMMenuViewDataSource, WMMenuViewDelegate, FileManagerViewDelegate>
@property (strong, nonatomic) WMMenuView *menu;
@property (strong, nonatomic) FileManagerView *listView;
@property (strong, nonatomic) PlayerDanmakuControlView *danmakuControlView;
@property (strong, nonatomic) PlayerControlView *playerControlView;
@end

@implementation PlayerConfigPanelView
{
    UIView *_currentView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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


- (CGFloat)menuView:(WMMenuView *)menu titleSizeForState:(WMMenuItemState)state {
    return NORMAL_SIZE_FONT.pointSize;
}

- (UIColor *)menuView:(WMMenuView *)menu titleColorForState:(WMMenuItemState)state {
    if (state == WMMenuItemStateNormal) {
        return [UIColor whiteColor];
    }
    return MAIN_COLOR;
}

- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    NSString *str = [self menuView:menu titleAtIndex:index];
    return [str sizeForFont:NORMAL_SIZE_FONT size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping].width + 20;
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

#pragma mark - FileManagerViewDelegate
- (void)managerView:(FileManagerView *)managerView didselectedModel:(JHFile *)file {
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

- (FileManagerView *)listView {
    if (_listView == nil) {
        _listView = [[FileManagerView alloc] init];
        _listView.delegate = self;
        _listView.type = FileManagerViewTypePlayerList;
        
//        @weakify(self)
//        [_listView setDidSelectedModelCallBack:^(VideoModel *model) {
//            @strongify(self)
//            if (![self.delegate respondsToSelector:@selector(playerConfigPanelView:didSelectedModel:)]) return;
//            
//            [self.delegate playerConfigPanelView:self didSelectedModel:model];
//        }];
    }
    return _listView;
}

- (PlayerDanmakuControlView *)danmakuControlView {
    if (_danmakuControlView == nil) {
        _danmakuControlView = [[PlayerDanmakuControlView alloc] init];
        @weakify(self)
        [_danmakuControlView setTouchStepperCallBack:^(CGFloat value) {
            @strongify(self)
            if (![self.delegate respondsToSelector:@selector(playerConfigPanelView:didTouchStepper:)]) return;
            
            [self.delegate playerConfigPanelView:self didTouchStepper:value];
        }];
    }
    return _danmakuControlView;
}

- (PlayerControlView *)playerControlView {
    if (_playerControlView == nil) {
        _playerControlView = [[PlayerControlView alloc] init];
    }
    return _playerControlView;
}

@end
