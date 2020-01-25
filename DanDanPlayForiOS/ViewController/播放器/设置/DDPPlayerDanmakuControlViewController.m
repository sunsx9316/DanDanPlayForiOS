//
//  DDPPlayerDanmakuControlViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPPlayerDanmakuControlViewController.h"

#import "DDPBaseTableView.h"
#import "DDPPlayerSliderTableViewCell.h"
#import "DDPPlayerControlHeaderView.h"
#import "DDPPlayerStepTableViewCell.h"
#import "DDPFileManagerFolderPlayerListViewCell.h"
#import "DDPPlayerShieldDanmakuTableViewCell.h"
#import "UIFont+Tools.h"
#import "DDPPlayerDanmakuControlModel.h"

@interface DDPPlayerDanmakuControlViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) NSArray <DDPPlayerDanmakuControlModel *>*dataSource;
@end

@implementation DDPPlayerDanmakuControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:model.reuseIdentifier forIndexPath:indexPath];
    if (model.dequeueReuseCellCallBack) {
        model.dequeueReuseCellCallBack(cell);
    }
    
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
        if (model.dequeueReuseHeaderCallBack) {
            model.dequeueReuseHeaderCallBack(view);
        }
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
        [_tableView registerNib:[DDPPlayerShieldDanmakuTableViewCell loadNib] forCellReuseIdentifier:[DDPPlayerShieldDanmakuTableViewCell className]];
        [_tableView registerClass:[DDPPlayerStepTableViewCell class] forCellReuseIdentifier:@"DDPPlayerStepTableViewCell"];
        [_tableView registerClass:[DDPFileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"DDPFileManagerFolderPlayerListViewCell"];
    }
    return _tableView;
}

- (NSArray<DDPPlayerDanmakuControlModel *> *)dataSource {
    if (_dataSource == nil) {
        NSMutableArray *arr = [NSMutableArray array];
        
        CGFloat rowHeight1 = 44 + ddp_isPad() * 20;
        __unused CGFloat rowHeight2 = 64 + ddp_isPad() * 20;
        CGFloat heightHeight1 = 30;
        __unused CGFloat heightHeight2 = CGFLOAT_MIN;
        
        @weakify(self)
        
        //弹幕大小
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPPlayerSliderTableViewCell class]);
            model.cellHeight = rowHeight1;
            model.headerHeight = heightHeight1;
            model.dequeueReuseCellCallBack = ^(DDPPlayerSliderTableViewCell *cell) {
                cell.type = DDPPlayerSliderTableViewCellTypeFontSize;
            };
            
            model.dequeueReuseHeaderCallBack = ^(DDPPlayerControlHeaderView *view) {
                view.titleLabel.text = @"弹幕字体大小";
            };
            
            [arr addObject:model];
        }
        
        //弹幕速度
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPPlayerSliderTableViewCell class]);
            model.cellHeight = rowHeight1;
            model.headerHeight = heightHeight1;
            model.dequeueReuseCellCallBack = ^(DDPPlayerSliderTableViewCell *cell) {
                cell.type = DDPPlayerSliderTableViewCellTypeSpeed;
            };
            
            model.dequeueReuseHeaderCallBack = ^(DDPPlayerControlHeaderView *view) {
                view.titleLabel.text = @"弹幕速度";
            };
            
            [arr addObject:model];
        }
        
        //弹幕透明度
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPPlayerSliderTableViewCell class]);
            model.cellHeight = rowHeight1;
            model.headerHeight = heightHeight1;
            model.dequeueReuseCellCallBack = ^(DDPPlayerSliderTableViewCell *cell) {
                cell.type = DDPPlayerSliderTableViewCellTypeOpacity;
            };
            
            model.dequeueReuseHeaderCallBack = ^(DDPPlayerControlHeaderView *view) {
                view.titleLabel.text = @"弹幕透明度";
            };
            
            [arr addObject:model];
        }
        
        //同屏弹幕数量
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPPlayerSliderTableViewCell class]);
            model.cellHeight = rowHeight1;
            model.headerHeight = heightHeight1;
            model.dequeueReuseCellCallBack = ^(DDPPlayerSliderTableViewCell *cell) {
                cell.type = DDPPlayerSliderTableViewCellTypeDanmakuLimit;
            };
            
            model.dequeueReuseHeaderCallBack = ^(DDPPlayerControlHeaderView *view) {
                view.titleLabel.text = @"同屏弹幕数量";
            };
            
            [arr addObject:model];
        }
        
        
        //弹幕边缘风格
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPPlayerShieldDanmakuTableViewCell class]);
            model.cellHeight = rowHeight1;
            model.headerHeight = heightHeight1;
            model.dequeueReuseCellCallBack = ^(DDPPlayerShieldDanmakuTableViewCell *cell) {
                cell.type = DDPPlayerShieldDanmakuTableViewCellTypeShadow;
            };
            
            model.dequeueReuseHeaderCallBack = ^(DDPPlayerControlHeaderView *view) {
                view.titleLabel.text = @"弹幕特效";
            };
            
            [arr addObject:model];
        }
        
        //快速屏蔽弹幕弹幕
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPPlayerShieldDanmakuTableViewCell class]);
            model.cellHeight = rowHeight1;
            model.headerHeight = heightHeight1;
            
            model.dequeueReuseCellCallBack = ^(DDPPlayerShieldDanmakuTableViewCell *cell) {
                cell.type = DDPPlayerShieldDanmakuTableViewCellTypeField;
            };
            
            model.dequeueReuseHeaderCallBack = ^(DDPPlayerControlHeaderView *view) {
                view.titleLabel.text = @"屏蔽弹幕";
            };
            
            [arr addObject:model];
        }
        
        //弹幕快进快退
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPPlayerStepTableViewCell class]);
            model.cellHeight = rowHeight1;
            model.headerHeight = heightHeight1;
            model.dequeueReuseCellCallBack = ^(DDPPlayerStepTableViewCell *cell) {
                @strongify(self)
                if (!self) return;
                
                cell.touchStepperCallBack = self.touchStepperCallBack;
            };
            
            model.dequeueReuseHeaderCallBack = ^(DDPPlayerControlHeaderView *view) {
                view.titleLabel.text = @"弹幕时间偏移";
            };
            
            [arr addObject:model];
        }
#if !DDPAPPTYPEISMAC
        //屏蔽弹幕
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPFileManagerFolderPlayerListViewCell class]);
            model.cellHeight = rowHeight2;
            model.headerHeight = heightHeight2;
            model.dequeueReuseCellCallBack = ^(DDPFileManagerFolderPlayerListViewCell *cell) {
                cell.titleLabel.textAlignment = NSTextAlignmentCenter;
                cell.titleLabel.text = @"屏蔽弹幕列表";
            };
            model.didSelectedRowCallBack = self.touchFilterDanmakuCellCallBack;
            [arr addObject:model];
        }
        
        //手动加载弹幕
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPFileManagerFolderPlayerListViewCell class]);
            model.cellHeight = rowHeight2;
            model.headerHeight = heightHeight2;
            model.dequeueReuseCellCallBack = ^(DDPFileManagerFolderPlayerListViewCell *cell) {
                cell.titleLabel.textAlignment = NSTextAlignmentCenter;
                cell.titleLabel.text = @"加载本地弹幕";
            };
            
            model.didSelectedRowCallBack = self.touchSelectedDanmakuCellCallBack;
            [arr addObject:model];
        }
        

        //手动匹配视频
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPFileManagerFolderPlayerListViewCell class]);
            model.cellHeight = rowHeight2;
            model.headerHeight = heightHeight2;
            model.dequeueReuseCellCallBack = ^(DDPFileManagerFolderPlayerListViewCell *cell) {
                cell.titleLabel.textAlignment = NSTextAlignmentCenter;
                cell.titleLabel.text = @"手动匹配视频";
            };
            model.didSelectedRowCallBack = self.touchMatchVideoCellCallBack;
            [arr addObject:model];
        }
        
        //其它设置
        {
            DDPPlayerDanmakuControlModel *model = [[DDPPlayerDanmakuControlModel alloc] init];
            model.reuseIdentifier = NSStringFromClass([DDPFileManagerFolderPlayerListViewCell class]);
            model.cellHeight = rowHeight2;
            model.headerHeight = heightHeight2;
            model.dequeueReuseCellCallBack = ^(DDPFileManagerFolderPlayerListViewCell *cell) {
                cell.titleLabel.textAlignment = NSTextAlignmentCenter;
                cell.titleLabel.text = @"其他设置";
            };
            model.didSelectedRowCallBack = self.touchOtherSettingCellCallBack;
            [arr addObject:model];
        }
#endif
        
        _dataSource = arr;
    }
    return _dataSource;
}
@end
