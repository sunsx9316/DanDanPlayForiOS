//
//  DDPMineViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMineViewController.h"
#import "DDPSettingViewController.h"
#import "DDPAboutUsViewController.h"
#import "DDPDownloadViewController.h"
#import "DDPAttentionListViewController.h"
#import "DDPLoginViewController.h"
#import "DDPControlVideoViewController.h"

#import "UIApplication+Tools.h"
#import "DDPSettingTitleTableViewCell.h"
#import "DDPSettingDownloadTableViewCell.h"
#import "UIView+Tools.h"
#import "DDPEdgeButton.h"
#import "DDPDownloadManager.h"

#define TITLE_KEY @"titleLabel.text"

#define TITLE_VIEW_RATE 0.4

@interface DDPMineViewController ()<UITableViewDelegate, UITableViewDataSource, DDPDownloadManagerObserver, UIScrollViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray <NSDictionary *>*dataSourceArr;
@property (strong, nonatomic) UIView *headView;
@property (strong, nonatomic) UIView *nameIconHoldView;
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) DDPEdgeButton *nameButton;
@property (strong, nonatomic) UIVisualEffectView *blurView;
@end

@implementation DDPMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"我的";
    
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self.view.height * TITLE_VIEW_RATE);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [[DDPDownloadManager shareDownloadManager] addObserver:self];
    [[DDPCacheManager shareCacheManager] addObserver:self forKeyPath:DDP_KEYPATH([DDPCacheManager shareCacheManager], user) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [[DDPToolsManager shareToolsManager] addObserver:self forKeyPath:DDP_KEYPATH([DDPToolsManager shareToolsManager], SMBSession) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self reloadUserInfo];
}

- (void)dealloc {
    [[DDPDownloadManager shareDownloadManager] removeObserver:self];
    [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:DDP_KEYPATH([DDPCacheManager shareCacheManager], user)];
    [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:DDP_KEYPATH([DDPToolsManager shareToolsManager], SMBSession)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:DDP_KEYPATH([DDPToolsManager shareToolsManager], SMBSession)]) {
        [self.tableView reloadData];
    }
    else if ([keyPath isEqualToString:DDP_KEYPATH([DDPCacheManager shareCacheManager], user)]) {
        [self reloadUserInfo];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = self.dataSourceArr[indexPath.row];
    
    DDPOtherSettingTitleSubtitleTableViewCell *cell = nil;
    
    if ([dic[TITLE_KEY] isEqualToString:@"下载任务"]) {
        DDPSettingDownloadTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:@"DDPSettingDownloadTableViewCell" forIndexPath:indexPath];
        aCell.downLoadCount = [DDPDownloadManager shareDownloadManager].tasks.count;
        cell = aCell;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DDPSettingTitleTableViewCell" forIndexPath:indexPath];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.titleLabel.textColor = [UIColor blackColor];
    [self.dataSourceArr[indexPath.row] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [cell setValue:obj forKeyPath:key];
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.dataSourceArr[indexPath.row];
    
    if ([dic[TITLE_KEY] isEqualToString:@"设置"]) {
        DDPSettingViewController *vc = [[DDPSettingViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([dic[TITLE_KEY] isEqualToString:@"我的关注"]) {
        DDPAttentionListViewController *vc = [[DDPAttentionListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([dic[TITLE_KEY] isEqualToString:@"下载任务"]) {
        DDPDownloadViewController *vc = [[DDPDownloadViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([dic[TITLE_KEY] isEqualToString:@"PC遥控器"]) {
        DDPControlVideoViewController *vc = [[DDPControlVideoViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        DDPAboutUsViewController *vc = [[DDPAboutUsViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44 + ddp_isPad() * 10;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float y = -scrollView.contentOffset.y / self.view.height * 4 + 1;
    if (y <= 1) y = 1;
    
    self.blurView.transform = CGAffineTransformMakeScale(y, y);
}

#pragma mark - DDPDownloadManagerObserver
- (void)tasksDidChange:(NSArray <id<DDPDownloadTaskProtocol>>*)tasks
                  type:(DDPDownloadTasksChangeType)type
                 error:(NSError *)error {
    [self.tableView reloadData];
}

#pragma mark - 私有方法
- (void)configLeftItem {
    
}

- (void)reloadUserInfo {
    DDPUser *user = [DDPCacheManager shareCacheManager].user;
    
    [self.blurView.layer ddp_setImageWithURL:user.icoImgURL placeholder:[UIImage imageNamed:@"comment_icon"]];
    [self.iconImgView ddp_setImageWithURL:user.icoImgURL placeholder:[UIImage imageNamed:@"comment_icon"]];
    if (user) {
        [self.nameButton setTitle:user.name forState:UIControlStateNormal];
    }
    else {
        [self.nameButton setTitle:@"点击登录" forState:UIControlStateNormal];
    }
    
    self.dataSourceArr = nil;
    [self.tableView reloadData];
}

- (void)editName {
    DDPUser *user = [DDPCacheManager shareCacheManager].user;
    
    if (user == nil) return;
    
    UIAlertController *avc = [UIAlertController alertControllerWithTitle:@"修改昵称" message:nil preferredStyle:UIAlertControllerStyleAlert];
    @weakify(avc)
    [avc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *name = weak_avc.textFields.firstObject.text;
        
        if (name.length == 0) {
            [self.view showWithText:@"请输入昵称!"];
            return;
        }
        
        [self.view showLoading];
        [DDPLoginNetManagerOperation loginEditUserNameWithUserId:user.identity token:user.token userName:name completionHandler:^(NSError *error) {
            [self.view hideLoading];
            
            if (error) {
                [self.view showWithError:error];
            }
            else {
                [self.view showWithText:@"修改成功!"];
                user.name = name;
                [DDPCacheManager shareCacheManager].user = user;
            }
        }];
    }]];
    
    [avc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [avc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont ddp_normalSizeFont];
        textField.placeholder = @"请输入昵称";
        textField.text = user.name;
    }];
    
    [self presentViewController:avc animated:YES completion:nil];
}

- (void)editPassword {
    DDPUser *user = [DDPCacheManager shareCacheManager].user;
    
    UIAlertController *avc = [UIAlertController alertControllerWithTitle:@"修改密码" message:nil preferredStyle:UIAlertControllerStyleAlert];
    @weakify(avc)
    [avc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *oldPassword = weak_avc.textFields.firstObject.text;
        NSString *newPassword = weak_avc.textFields[1].text;
        
        if (oldPassword.length == 0) {
            [self.view showWithText:@"请输入原密码！"];
            return;
        }
        
        if (newPassword.length == 0) {
            [self.view showWithText:@"请输入新密码！"];
            return;
        }
        
        [self.view showLoading];
        [DDPLoginNetManagerOperation loginEditPasswordWithUserId:user.identity token:user.token oldPassword:oldPassword aNewPassword:newPassword completionHandler:^(NSError *error) {
            [self.view hideLoading];
            if (error) {
                [self.view showWithError:error];
            }
            else {
                [self.view showWithText:@"修改成功！"];
            }
        }];
    }]];
    
    [avc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [avc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont ddp_normalSizeFont];
        textField.placeholder = @"原密码";
        textField.secureTextEntry = YES;
    }];
    
    [avc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont ddp_normalSizeFont];
        textField.placeholder = @"新密码";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:avc animated:YES completion:nil];
}

#pragma mark - 懒加载

- (UIView *)headView {
    if (_headView == nil) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height * TITLE_VIEW_RATE)];
        _headView.clipsToBounds = YES;
        
        [_headView addSubview:self.nameIconHoldView];
        
        [self.nameIconHoldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
        }];
        
        @weakify(self)
        [_headView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            DDPUser *user = [DDPCacheManager shareCacheManager].user;
            
            if (user == nil) {
                DDPLoginViewController *vc = [[DDPLoginViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                
                if (user.userType == DDPUserTypeDefault) {
                    [vc addAction:[UIAlertAction actionWithTitle:@"修改密码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self editPassword];
                    }]];
                    
                    [vc addAction:[UIAlertAction actionWithTitle:@"修改昵称" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self editName];
                    }]];
                }
                
                [vc addAction:[UIAlertAction actionWithTitle:@"退出登录" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [DDPCacheManager shareCacheManager].lastLoginUser = [DDPCacheManager shareCacheManager].user;
                    [DDPCacheManager shareCacheManager].user = nil;
                    [self reloadUserInfo];
                }]];
                
                [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                
                if (ddp_isPad()) {
                    vc.popoverPresentationController.sourceView = self.view;
                    vc.popoverPresentationController.sourceRect = [self.view convertRect:self.nameButton.frame fromView:self.nameIconHoldView];
                }
                
                [self presentViewController:vc animated:YES completion:nil];
            }
        }]];
    }
    return _headView;
}

- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImgView.layer.cornerRadius = (90 + ddp_isPad() * 40) / 2;
        _iconImgView.layer.masksToBounds = YES;
        _iconImgView.layer.borderWidth = 5;
        _iconImgView.layer.borderColor = DDPRGBAColor(255, 255, 255, 0.6).CGColor;
    }
    return _iconImgView;
}

- (DDPEdgeButton *)nameButton {
    if (_nameButton == nil) {
        _nameButton = [[DDPEdgeButton alloc] init];
        _nameButton.inset = CGSizeMake(10, 0);
        _nameButton.userInteractionEnabled = NO;
        _nameButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_nameButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _nameButton;
}

- (UIView *)nameIconHoldView {
    if (_nameIconHoldView == nil) {
        _nameIconHoldView = [[UIView alloc] init];
        _nameIconHoldView.clipsToBounds = NO;
        [_nameIconHoldView addSubview:self.iconImgView];
        [_nameIconHoldView addSubview:self.nameButton];
        
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
            make.width.height.mas_equalTo(90 + ddp_isPad() * 40);
        }];
        
        [self.nameButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImgView.mas_bottom).mas_offset(10);
            make.bottom.mas_offset(-10);
            //            make.centerX.mas_equalTo(0);
            make.left.right.mas_equalTo(0);
            make.width.mas_greaterThanOrEqualTo(self.iconImgView);
        }];
        
    }
    return _nameIconHoldView;
}

- (UIVisualEffectView *)blurView {
    if (_blurView == nil) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _blurView.layer.contentMode = UIViewContentModeScaleAspectFill;
        _blurView.layer.masksToBounds = YES;
        [self.view addSubview:_blurView];
    }
    return _blurView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableHeaderView = self.headView;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [_tableView registerClass:[DDPSettingTitleTableViewCell class] forCellReuseIdentifier:@"DDPSettingTitleTableViewCell"];
        [_tableView registerClass:[DDPSettingDownloadTableViewCell class] forCellReuseIdentifier:@"DDPSettingDownloadTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<NSDictionary *> *)dataSourceArr {
    if (_dataSourceArr == nil) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:
                               @[
                                 @{TITLE_KEY: @"设置"},
                                 @{TITLE_KEY: @"下载任务"},
                                 @{TITLE_KEY: @"PC遥控器"},
                                 @{TITLE_KEY: [NSString stringWithFormat:@"关于%@", [UIApplication sharedApplication].appDisplayName]}
                                 ]];
        
        if ([DDPCacheManager shareCacheManager].user) {
            [arr insertObject:@{TITLE_KEY: @"我的关注"} atIndex:0];
        }
        
        _dataSourceArr = arr;
    }
    return _dataSourceArr;
}

@end

