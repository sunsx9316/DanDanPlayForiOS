//
//  DDPPlayerDanmakuControlView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerDanmakuControlView.h"
//#import "PickerFileViewController.h"

#import "DDPBaseTableView.h"
#import "DDPPlayerSliderTableViewCell.h"
#import "DDPPlayerControlHeaderView.h"
#import "DDPPlayerShadowStyleTableViewCell.h"
#import "DDPPlayerStepTableViewCell.h"
#import "DDPFileManagerFolderPlayerListViewCell.h"
#import "UIFont+Tools.h"
#import "DDPPlayerDanmakuControlModel.h"

@interface DDPPlayerDanmakuControlView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) NSArray <DDPPlayerDanmakuControlModel *>*dataSource;
@end

@implementation DDPPlayerDanmakuControlView

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
    
    DDPPlayerDanmakuControlModel *model = self.dataSource[indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.initializeClass forIndexPath:indexPath];
    [model.cellDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [cell setValue:obj forKeyPath:key];
    }];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    DDPPlayerDanmakuControlModel *model = self.dataSource[indexPath.section];
    if (model.didSelectedRowCallBack) {
        model.didSelectedRowCallBack();
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPPlayerDanmakuControlModel *model = self.dataSource[indexPath.section];
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    DDPPlayerDanmakuControlModel *model = self.dataSource[section];
    return model.headerHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDPPlayerDanmakuControlModel *model = self.dataSource[section];
    if (model.headerHeight > CGFLOAT_MIN) {
        DDPPlayerControlHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDPPlayerControlHeaderView"];
        [model.headerDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [view setValue:obj forKeyPath:key];
        }];
        return view;
    }
    return nil;
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[DDPPlayerSliderTableViewCell class] forCellReuseIdentifier:@"DDPPlayerSliderTableViewCell"];
        [_tableView registerClass:[DDPPlayerControlHeaderView class] forHeaderFooterViewReuseIdentifier:@"DDPPlayerControlHeaderView"];
        [_tableView registerClass:[DDPPlayerShadowStyleTableViewCell class] forCellReuseIdentifier:@"DDPPlayerShadowStyleTableViewCell"];
        [_tableView registerClass:[DDPPlayerStepTableViewCell class] forCellReuseIdentifier:@"DDPPlayerStepTableViewCell"];
        [_tableView registerClass:[DDPFileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"DDPFileManagerFolderPlayerListViewCell"];
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<DDPPlayerDanmakuControlModel *> *)dataSource {
    if (_dataSource == nil) {
        NSMutableArray *arr = [NSMutableArray array];

        CGFloat rowHeight1 = 44 + ddp_isPad() * 20;
        CGFloat rowHeight2 = 64 + ddp_isPad() * 20;
        CGFloat heightHeight1 = 30;
        CGFloat heightHeight2 = CGFLOAT_MIN;
        
        //弹幕大小
        {
            DDPPlayerDanmakuControlModel *cell = [[DDPPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"DDPPlayerSliderTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            cell.cellDic = @{@"type" : @(DDPPlayerSliderTableViewCellTypeFontSize)};
            
            cell.headerDic = @{@"titleLabel.text" : @"弹幕字体大小"};
            
            [arr addObject:cell];
        }
        
        //弹幕速度
        {
            DDPPlayerDanmakuControlModel *cell = [[DDPPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"DDPPlayerSliderTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            cell.cellDic = @{@"type" : @(DDPPlayerSliderTableViewCellTypeSpeed)};
            
            cell.headerDic = @{@"titleLabel.text" : @"弹幕速度"};
            
            [arr addObject:cell];
        }
        
        //弹幕透明度
        {
            DDPPlayerDanmakuControlModel *cell = [[DDPPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"DDPPlayerSliderTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            cell.cellDic = @{@"type" : @(DDPPlayerSliderTableViewCellTypeOpacity)};
            
            cell.headerDic = @{@"titleLabel.text" : @"弹幕透明度"};
            
            [arr addObject:cell];
        }
        
        //同屏弹幕数量
        {
            DDPPlayerDanmakuControlModel *cell = [[DDPPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"DDPPlayerSliderTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            cell.cellDic = @{@"type" : @(DDPPlayerSliderTableViewCellTypeDanmakuLimit)};
            
            cell.headerDic = @{@"titleLabel.text" : @"同屏弹幕数量"};
            
            [arr addObject:cell];
        }
        
        
        //弹幕边缘风格
        {
            DDPPlayerDanmakuControlModel *cell = [[DDPPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"DDPPlayerShadowStyleTableViewCell";
            cell.cellHeight = rowHeight1;
            cell.headerHeight = heightHeight1;
            
            cell.headerDic = @{@"titleLabel.text" : @"弹幕特效"};
            
            [arr addObject:cell];
        }
        
        //弹幕快进快退
        {
            DDPPlayerDanmakuControlModel *cell = [[DDPPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"DDPPlayerStepTableViewCell";
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
            DDPPlayerDanmakuControlModel *cell = [[DDPPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"DDPFileManagerFolderPlayerListViewCell";
            cell.cellHeight = rowHeight2;
            cell.headerHeight = heightHeight2;
            cell.cellDic = @{@"titleLabel.textAlignment" : @(NSTextAlignmentCenter), @"titleLabel.text" : @"屏蔽弹幕"};
            cell.didSelectedRowCallBack = self.touchFilterDanmakuCellCallBack;
            [arr addObject:cell];
        }
        
        //手动加载弹幕
        {
            DDPPlayerDanmakuControlModel *cell = [[DDPPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"DDPFileManagerFolderPlayerListViewCell";
            cell.cellHeight = rowHeight2;
            cell.headerHeight = heightHeight2;
            cell.cellDic = @{@"titleLabel.textAlignment" : @(NSTextAlignmentCenter), @"titleLabel.text" : @"手动加载弹幕..."};
            cell.didSelectedRowCallBack = self.touchSelectedDanmakuCellCallBack;
            [arr addObject:cell];
        }
        
        //手动匹配视频
        {
            DDPPlayerDanmakuControlModel *cell = [[DDPPlayerDanmakuControlModel alloc] init];
            cell.initializeClass = @"DDPFileManagerFolderPlayerListViewCell";
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
