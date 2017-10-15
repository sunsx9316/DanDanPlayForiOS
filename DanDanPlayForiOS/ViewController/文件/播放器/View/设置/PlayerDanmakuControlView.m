//
//  PlayerDanmakuControlView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerDanmakuControlView.h"
//#import "PickerFileViewController.h"

#import "JHBaseTableView.h"
#import "PlayerSliderTableViewCell.h"
#import "PlayerControlHeaderView.h"
#import "PlayerShadowStyleTableViewCell.h"
#import "PlayerStepTableViewCell.h"
#import "FileManagerFolderPlayerListViewCell.h"
#import "UIFont+Tools.h"
#import "JHPlayerDanmakuControlModel.h"

@interface PlayerDanmakuControlView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) NSArray <JHPlayerDanmakuControlModel *>*dataSource;
@end

@implementation PlayerDanmakuControlView

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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JHPlayerDanmakuControlModel *model = self.dataSource[indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.initializeClass forIndexPath:indexPath];
    [model.cellDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [cell setValue:obj forKeyPath:key];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JHPlayerDanmakuControlModel *model = self.dataSource[indexPath.section];
    if (model.didSelectedRowCallBack) {
        model.didSelectedRowCallBack();
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHPlayerDanmakuControlModel *model = self.dataSource[indexPath.section];
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    JHPlayerDanmakuControlModel *model = self.dataSource[section];
    return model.headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    JHPlayerDanmakuControlModel *model = self.dataSource[section];
    if (model.headerHeight > 0.1) {
        PlayerControlHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"PlayerControlHeaderView"];
        [model.headerDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [view setValue:obj forKeyPath:key];
        }];
        return view;
    }
    return nil;
}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[PlayerSliderTableViewCell class] forCellReuseIdentifier:@"PlayerSliderTableViewCell"];
        [_tableView registerClass:[PlayerControlHeaderView class] forHeaderFooterViewReuseIdentifier:@"PlayerControlHeaderView"];
        [_tableView registerClass:[PlayerShadowStyleTableViewCell class] forCellReuseIdentifier:@"PlayerShadowStyleTableViewCell"];
        [_tableView registerClass:[PlayerStepTableViewCell class] forCellReuseIdentifier:@"PlayerStepTableViewCell"];
        [_tableView registerClass:[FileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"FileManagerFolderPlayerListViewCell"];
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<JHPlayerDanmakuControlModel *> *)dataSource {
    if (_dataSource == nil) {
        NSMutableArray *arr = [NSMutableArray array];

        CGFloat rowHeight1 = 44 + jh_isPad() * 20;
        CGFloat rowHeight2 = 64 + jh_isPad() * 20;
        CGFloat heightHeight1 = 30;
        CGFloat heightHeight2 = 0.1;
        
        //弹幕大小
        {
            JHPlayerDanmakuControlModel *cell = [[JHPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"PlayerSliderTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            cell.cellDic = @{@"type" : @(PlayerSliderTableViewCellTypeFontSize)};
            
            cell.headerDic = @{@"titleLabel.text" : @"弹幕字体大小"};
            
            [arr addObject:cell];
        }
        
        //弹幕速度
        {
            JHPlayerDanmakuControlModel *cell = [[JHPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"PlayerSliderTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            cell.cellDic = @{@"type" : @(PlayerSliderTableViewCellTypeSpeed)};
            
            cell.headerDic = @{@"titleLabel.text" : @"弹幕速度"};
            
            [arr addObject:cell];
        }
        
        //弹幕透明度
        {
            JHPlayerDanmakuControlModel *cell = [[JHPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"PlayerSliderTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            cell.cellDic = @{@"type" : @(PlayerSliderTableViewCellTypeOpacity)};
            
            cell.headerDic = @{@"titleLabel.text" : @"弹幕透明度"};
            
            [arr addObject:cell];
        }
        
        //同屏弹幕数量
        {
            JHPlayerDanmakuControlModel *cell = [[JHPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"PlayerSliderTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            cell.cellDic = @{@"type" : @(PlayerSliderTableViewCellTypeDanmakuLimit)};
            
            cell.headerDic = @{@"titleLabel.text" : @"同屏弹幕数量"};
            
            [arr addObject:cell];
        }
        
        
        //弹幕边缘风格
        {
            JHPlayerDanmakuControlModel *cell = [[JHPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"PlayerShadowStyleTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            
            cell.headerDic = @{@"titleLabel.text" : @"弹幕特效"};
            
            [arr addObject:cell];
        }
        
        //弹幕快进快退
        {
            JHPlayerDanmakuControlModel *cell = [[JHPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"PlayerStepTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            cell.cellDic = @{@"touchStepperCallBack" : ^(CGFloat value){
                if (self.touchStepperCallBack) {
                    self.touchStepperCallBack(value);
                }
            }};
            
            cell.headerDic = @{@"titleLabel.text" : @"弹幕时间偏移"};
            
            [arr addObject:cell];
        }
        
        //屏蔽弹幕
        {
            JHPlayerDanmakuControlModel *cell = [[JHPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"FileManagerFolderPlayerListViewCell";
            cell.cellHeight = rowHeight2;
            cell.headerHeight = heightHeight2;
            cell.cellDic = @{@"titleLabel.textAlignment" : @(NSTextAlignmentCenter), @"titleLabel.text" : @"屏蔽弹幕"};
            cell.didSelectedRowCallBack = self.touchFilterDanmakuCellCallBack;
            [arr addObject:cell];
        }
        
        //手动加载弹幕
        {
            JHPlayerDanmakuControlModel *cell = [[JHPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"FileManagerFolderPlayerListViewCell";
            cell.cellHeight = rowHeight2;
            cell.headerHeight = heightHeight2;
            cell.cellDic = @{@"titleLabel.textAlignment" : @(NSTextAlignmentCenter), @"titleLabel.text" : @"手动加载弹幕..."};
            cell.didSelectedRowCallBack = self.touchSelectedDanmakuCellCallBack;
            [arr addObject:cell];
        }
        
        //手动匹配视频
        {
            JHPlayerDanmakuControlModel *cell = [[JHPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"FileManagerFolderPlayerListViewCell";
            cell.cellHeight = rowHeight2;
            cell.headerHeight = heightHeight2;
            cell.cellDic = @{@"titleLabel.textAlignment" : @(NSTextAlignmentCenter), @"titleLabel.text" : @"手动匹配视频"};
            cell.didSelectedRowCallBack = self.touchMatchVideoCellCallBack;
            [arr addObject:cell];
        }
        
        _dataSource = arr;
    }
    return _dataSource;
}

@end
