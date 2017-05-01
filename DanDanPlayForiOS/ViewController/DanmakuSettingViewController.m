//
//  DanmakuSettingViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DanmakuSettingViewController.h"
#import "DanmakuSelectedFontViewController.h"
#import "SettingTitleTableViewCell.h"

#import "UIFont+Tools.h"
#import <UITableView+FDTemplateLayoutCell.h>

@interface DanmakuSettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation DanmakuSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"danmakuFont" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)dealloc {
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"danmakuFont"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"danmakuFont"]) {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DanmakuSelectedFontViewController *vc = [[DanmakuSelectedFontViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SettingTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingTitleTableViewCell" forIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        cell.titleLabel.text = @"弹幕字体";
        UIFont *font = [CacheManager shareCacheManager].danmakuFont;
        cell.detailLabel.font = [font fontWithSize:NORMAL_SIZE_FONT.pointSize];
        if (font.isSystemFont) {
            cell.detailLabel.text = @"系统字体";
        }
        else {
            cell.detailLabel.text = font.fontName;
        }
    }
    
    return cell;

}



#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 44;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [_tableView registerClass:[SettingTitleTableViewCell class] forCellReuseIdentifier:@"SettingTitleTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];

        [self.view addSubview:_tableView];
    }
    return _tableView;
}


@end
