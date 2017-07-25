//
//  PlayerVideoControlView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerVideoControlView.h"
#import "PickerFileViewController.h"

#import "PlayerControlHeaderView.h"
#import "FTPReceiceTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>

@interface PlayerVideoControlView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        FTPReceiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FTPReceiceTableViewCell"];
        if (cell == nil) {
            cell = [[FTPReceiceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FTPReceiceTableViewCell"];
            cell.titleLabel.textColor = [UIColor whiteColor];
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
    return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    PlayerControlHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"PlayerControlHeaderView"];
    view.titleLabel.text = @"播放模式";
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[PlayerControlHeaderView class] forHeaderFooterViewReuseIdentifier:@"PlayerControlHeaderView"];
        [self addSubview:_tableView];
    }
    return _tableView;
}

@end
