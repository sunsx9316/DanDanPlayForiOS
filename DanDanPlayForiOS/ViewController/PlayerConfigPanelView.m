//
//  PlayerConfigPanelView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerConfigPanelView.h"
#import <WMMenuView.h>
#import "PlayerListView.h"
#import "PlayerControlView.h"

@interface PlayerConfigPanelView ()<WMMenuViewDataSource, WMMenuViewDelegate>
@property (strong, nonatomic) WMMenuView *menu;
@property (strong, nonatomic) PlayerListView *listView;
@property (strong, nonatomic) PlayerControlView *controlView;
@end

@implementation PlayerConfigPanelView
{
    PlayerListView *_playerListView;
    PlayerControlView *_playerControlView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.menu mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.left.right.mas_equalTo(0);
            make.height.mas_equalTo(40);
        }];
        
        [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.menu.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
        }];
        
//        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.menu.mas_bottom);
//            make.left.right.bottom.mas_equalTo(0);
//        }];
    }
    return self;
}

- (void)reloadData {
    [_playerListView reloadData];
}

#pragma mark - WMMenuViewDelegate
- (void)menuView:(WMMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    
    if (currentIndex == index) return;
    
    if (index == 0) {
        if (self.controlView.superview) {
            [self.controlView removeFromSuperview];
        }
        
        [self addSubview:self.listView];
        [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.menu.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
    
    if (index == 1) {
        if (self.listView.superview) {
            [self.listView removeFromSuperview];
        }
        
        [self addSubview:self.controlView];
        [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.menu.mas_bottom);
            make.left.right.bottom.mas_equalTo(0);
        }];
    }
}


- (CGFloat)menuView:(WMMenuView *)menu titleSizeForState:(WMMenuItemState)state {
    return 14;
}

- (UIColor *)menuView:(WMMenuView *)menu titleColorForState:(WMMenuItemState)state {
    if (state == WMMenuItemStateNormal) {
        return [UIColor whiteColor];
    }
    return MAIN_COLOR;
}

#pragma mark - WMMenuViewDataSource
- (NSInteger)numbersOfTitlesInMenuView:(WMMenuView *)menu {
    return 2;
}

- (NSString *)menuView:(WMMenuView *)menu titleAtIndex:(NSInteger)index {
    if (index == 0) {
        return @"播放列表";
    }
    return @"弹幕设置";
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

- (PlayerListView *)listView {
    if (_listView == nil) {
        _listView = [[PlayerListView alloc] init];
        [self addSubview:_listView];
    }
    return _listView;
}

- (PlayerControlView *)controlView {
    if (_controlView == nil) {
        _controlView = [[PlayerControlView alloc] init];
        @weakify(self)
        [_controlView setTouchStepperCallBack:^(CGFloat value) {
            @strongify(self)
            if (![self.delegate respondsToSelector:@selector(playerConfigPanelView:didTouchStepper:)]) return;
            
            [self.delegate playerConfigPanelView:self didTouchStepper:value];
        }];
        [self addSubview:_controlView];
    }
    return _controlView;
}

@end
