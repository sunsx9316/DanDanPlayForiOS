//
//  SettingViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SettingViewController.h"
#import "DanmakuSettingViewController.h"
#import "OtherSettingViewController.h"
#import "AboutUsViewController.h"

#import "UIApplication+Tools.h"

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray <NSDictionary *>*dataSourceArr;
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) UIImageView *iconBGImgView;
@property (strong, nonatomic) UIImageView *iconImgView;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"设置";
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.textLabel.font = NORMAL_SIZE_FONT;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    [self.dataSourceArr[indexPath.row] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [cell setValue:obj forKeyPath:key];
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        DanmakuSettingViewController *vc = [[DanmakuSettingViewController alloc] init];
        vc.title = self.dataSourceArr[indexPath.row][@"textLabel.text"];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 1) {
        OtherSettingViewController *vc = [[OtherSettingViewController alloc] init];
        vc.title = self.dataSourceArr[indexPath.row][@"textLabel.text"];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (indexPath.row == 2) {
        AboutUsViewController *vc = [[AboutUsViewController alloc] init];
        vc.title = self.dataSourceArr[indexPath.row][@"textLabel.text"];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 私有方法
- (void)configLeftItem {
    
}

- (void)reloadUserInfo {
    [self.iconBGImgView jh_setImageWithURL:[CacheManager shareCacheManager].user.icoImgURL placeholder:[UIImage imageNamed:@"icon"]];
    [self.iconImgView jh_setImageWithURL:[CacheManager shareCacheManager].user.icoImgURL  placeholder:[UIImage imageNamed:@"icon"]];
}

#pragma mark - 懒加载

- (UIView *)headView {
    if (_headView == nil) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height * 0.3)];
        _headView.clipsToBounds = YES;
        
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        [_headView addSubview:self.iconBGImgView];
        [_headView addSubview:blurView];
        [_headView addSubview:self.iconImgView];
        
        [self.iconBGImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [blurView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
            make.width.height.mas_equalTo(80);
        }];
        
        [self reloadUserInfo];
    }
    return _headView;
}

- (UIImageView *)iconBGImgView {
    if (_iconBGImgView == nil) {
        _iconBGImgView = [[UIImageView alloc] init];
        _iconBGImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _iconBGImgView;
}

- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImgView.layer.cornerRadius = 40;
        _iconImgView.layer.masksToBounds = YES;
        _iconImgView.layer.borderWidth = 3;
        _iconImgView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _iconImgView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableHeaderView = self.headView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<NSDictionary *> *)dataSourceArr {
    if (_dataSourceArr == nil) {
        _dataSourceArr = @[@{@"textLabel.text": @"弹幕设置"},
                           @{@"textLabel.text": @"其他设置"},
                           @{@"textLabel.text": [NSString stringWithFormat:@"关于%@", [UIApplication sharedApplication].appDisplayName]},];
        
    }
    return _dataSourceArr;
}

@end
