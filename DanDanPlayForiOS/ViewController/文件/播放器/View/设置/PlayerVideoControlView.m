//
//  PlayerVideoControlView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerVideoControlView.h"
//#import "PickerFileViewController.h"

#import "PlayerControlHeaderView.h"
#import "FTPReceiceTableViewCell.h"
#import "PlayerSliderTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "JHMediaPlayer.h"
#import "JHBaseTableView.h"

@interface PlayerVideoControlView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) JHBaseTableView *tableView;
@end

@implementation PlayerVideoControlView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        PlayerSliderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerSliderTableViewCell" forIndexPath:indexPath];
        cell.type = PlayerSliderTableViewCellTypeRate;
        return cell;
    }
    
    FTPReceiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FTPReceiceTableViewCell" forIndexPath:indexPath];
    if (cell.isFromCache == NO) {
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.fromCache = YES;
    }
    
    if (indexPath.row == [CacheManager shareCacheManager].playMode) {
        cell.iconImgView.hidden = NO;
    }
    else {
        cell.iconImgView.hidden = YES;
    }
    
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"单集播放";
    }
    else if (indexPath.row == 1) {
        cell.titleLabel.text = @"单集循环";
    }
    else if (indexPath.row == 2) {
        cell.titleLabel.text = @"列表循环";
    }
    else if (indexPath.row == 3) {
        cell.titleLabel.text = @"顺序播放";
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [CacheManager shareCacheManager].playMode = indexPath.row;
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44 + jh_isPad() * 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlayerControlHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"PlayerControlHeaderView"];
    if (section == 0) {
        view.titleLabel.text = @"播放速度";
    }
    else {
        view.titleLabel.text = @"播放模式";
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[FTPReceiceTableViewCell class] forCellReuseIdentifier:@"FTPReceiceTableViewCell"];
        [_tableView registerClass:[PlayerSliderTableViewCell class] forCellReuseIdentifier:@"PlayerSliderTableViewCell"];
        [_tableView registerClass:[PlayerControlHeaderView class] forHeaderFooterViewReuseIdentifier:@"PlayerControlHeaderView"];
        [self addSubview:_tableView];
    }
    return _tableView;
}

@end
