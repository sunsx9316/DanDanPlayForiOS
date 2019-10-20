//
//  DDPPlayerVideoControlViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPPlayerVideoControlViewController.h"
#import "DDPPlayerControlHeaderView.h"
#import "DDPSelectedTableViewCell.h"
#import "DDPPlayerSliderTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "DDPBaseTableView.h"

@interface DDPPlayerVideoControlViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) NSArray <NSValue *>*videoAspectRatios;
@end

@implementation DDPPlayerVideoControlViewController
{
    __weak NSValue *_selectedVideoAspectRatio;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    _selectedVideoAspectRatio = self.videoAspectRatios.firstObject;
}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (ddp_appType == DDPAppTypeToMac) {
        return 1;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DDPPlayerSliderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPPlayerSliderTableViewCell" forIndexPath:indexPath];
        cell.type = DDPPlayerSliderTableViewCellTypeRate;
        return cell;
    }
    
    if (indexPath.section == 1) {
        DDPSelectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPSelectedTableViewCell" forIndexPath:indexPath];
        if (cell.isFromCache == NO) {
            cell.titleLabel.textColor = [UIColor whiteColor];
            cell.fromCache = YES;
        }
        
        CGSize size = _selectedVideoAspectRatio.CGSizeValue;
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            cell.titleLabel.text = @"默认";
        }
        else {
            cell.titleLabel.text = [NSString stringWithFormat:@"%ld : %ld", (long)size.width, (long)size.height];
        }
        cell.iconImgView.hidden = YES;
        return cell;
    }
    
    DDPSelectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPSelectedTableViewCell" forIndexPath:indexPath];
    if (cell.isFromCache == NO) {
        cell.titleLabel.textColor = [UIColor whiteColor];
        cell.fromCache = YES;
    }
    
    if (indexPath.row == [DDPCacheManager shareCacheManager].playMode) {
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
    if (indexPath.section == 1) {
        NSInteger index = [self.videoAspectRatios indexOfObject:_selectedVideoAspectRatio];
        if (index != NSNotFound) {
            index = (index + 1) % self.videoAspectRatios.count;
            _selectedVideoAspectRatio = self.videoAspectRatios[index];
            [DDPCacheManager shareCacheManager].videoAspectRatio = _selectedVideoAspectRatio.CGSizeValue;
            [tableView reloadSection:1 withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if (indexPath.section == 2) {
        [DDPCacheManager shareCacheManager].playMode = indexPath.row;
        [tableView reloadData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44 + ddp_isPad() * 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDPPlayerControlHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDPPlayerControlHeaderView"];
    if (section == 0) {
        view.titleLabel.text = @"播放速度";
    }
    else if (section == 1) {
        view.titleLabel.text = @"视频比例";
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
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[DDPSelectedTableViewCell class] forCellReuseIdentifier:@"DDPSelectedTableViewCell"];
        [_tableView registerClass:[DDPPlayerSliderTableViewCell class] forCellReuseIdentifier:@"DDPPlayerSliderTableViewCell"];
        [_tableView registerClass:[DDPPlayerControlHeaderView class] forHeaderFooterViewReuseIdentifier:@"DDPPlayerControlHeaderView"];
    }
    return _tableView;
}

- (NSArray<NSValue *> *)videoAspectRatios {
    if (_videoAspectRatios == nil) {
        _videoAspectRatios = @[@(CGSizeZero), @(CGSizeMake(16, 9)), @(CGSizeMake(4, 3))];
    }
    return _videoAspectRatios;
}
@end
