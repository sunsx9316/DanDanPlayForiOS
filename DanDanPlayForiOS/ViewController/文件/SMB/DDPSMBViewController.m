//
//  DDPSMBViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSMBViewController.h"
#import "DDPSMBFileViewController.h"
#import "DDPHelpViewController.h"

#import "DDPFileManagerFolderPlayerListViewCell.h"
#import "DDPSMBLoginHeaderView.h"
#import "DDPSMBLoginView.h"

#import <TOSMBClient.h>
#import "DDPBaseTableView.h"
#import "NSString+Tools.h"

@interface DDPSMBViewController ()<UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) NSMutableArray <TONetBIOSNameServiceEntry *>*nameServiceEntries;
@property (strong, nonatomic) TONetBIOSNameService *netbiosService;
@end

@implementation DDPSMBViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.netbiosService stopDiscovery];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"局域网设备";
    [self configRightItem];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (self.tableView.mj_header.refreshingBlock) {
        self.tableView.mj_header.refreshingBlock();
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.nameServiceEntries.count;
    }
    return [DDPCacheManager shareCacheManager].SMBLinkInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPFileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
    if (cell.isFromCache == NO) {
        cell.titleLabel.textColor = [UIColor blackColor];
//        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor]]];
//        cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
//        cell.delegate = self;
        [cell.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(15);
            make.bottom.mas_offset(-15);
        }];
        cell.fromCache = YES;
    }
    
    if (indexPath.section == 0) {
        TONetBIOSNameServiceEntry *entry = self.nameServiceEntries[indexPath.row];
        cell.titleLabel.text = entry.name;
    }
    else {
        DDPSMBInfo *model = [DDPCacheManager shareCacheManager].SMBLinkInfos[indexPath.row];
        cell.titleLabel.text = model.hostName.length ? model.hostName : model.ipAddress;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 40;
    }
    
    if (([DDPCacheManager shareCacheManager].SMBLinkInfos.count)) {
        return 40;
    }
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        TONetBIOSNameServiceEntry *entry = self.nameServiceEntries[indexPath.row];
        DDPSMBInfo *info = [[DDPSMBInfo alloc] init];
        info.hostName = entry.name;
        [self showAlertViewControllerWithModel:info];
    }
    //点击历史
    else if (indexPath.section == 1) {
        [self loginWithModel:[DDPCacheManager shareCacheManager].SMBLinkInfos[indexPath.row] completion:nil];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        DDPSMBLoginHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDPSMBLoginHeaderView"];
        view.titleLabel.text = @"本地局域网设备";
        return view;
    }
    
    if ([DDPCacheManager shareCacheManager].SMBLinkInfos.count) {
        DDPSMBLoginHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDPSMBLoginHeaderView"];
        view.titleLabel.text = @"登录历史";
        return view;
    }
    
    return nil;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return @[^{
            UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull aIndexPath) {
                DDPSMBInfo *model = [DDPCacheManager shareCacheManager].SMBLinkInfos[aIndexPath.row];
                [self touchDeleteButtonWithAction:model];
            }];
            action.backgroundColor = DDPRGBColor(255, 48, 54);
            return action;
        }()];
    }
    
    return @[];
}

//#pragma mark - MGSwipeTableCellDelegate
//- (BOOL)swipeTableCell:(nonnull MGSwipeTableCell*)cell canSwipe:(MGSwipeDirection) direction {
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    return indexPath.section == 1;
//}

//- (BOOL)swipeTableCell:(nonnull MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
//    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    if (indexPath.section == 1) {
//        DDPSMBInfo *model = [DDPCacheManager shareCacheManager].SMBLinkInfos[indexPath.row];
//        [[DDPCacheManager shareCacheManager] removeSMBInfo:model];
//        [self.tableView reloadData];
//    }
//    return YES;
//}

#pragma mark - 私有方法
- (void)loginWithModel:(DDPSMBInfo *)model completion:(void(^)(BOOL success))completion {
    
    [self.view showLoadingWithText:@"连接中..."];
    
    void(^loginAction)(DDPSMBInfo *) = ^(DDPSMBInfo *aModel) {
        [DDPToolsManager shareToolsManager].smbInfo = aModel;
        [[DDPToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:nil completion:^(DDPSMBFile *file, NSError *error) {
            [self.view hideLoading];
            
            if (completion) {
                completion(error == nil);
            }

            if (error) {
                [self.view showWithError:error];
                [DDPToolsManager shareToolsManager].smbInfo = nil;
            }
            else {
                [[DDPCacheManager shareCacheManager] saveSMBInfo:aModel];
                [self.tableView reloadData];

                DDPSMBFileViewController *vc = [[DDPSMBFileViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                vc.file = file;
                vc.title = aModel.hostName;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    };

    if (model.ipAddress.length && model.hostName.length == 0) {
        [self.netbiosService lookupNetworkNameForIPAddress:model.ipAddress success:^(NSString *name) {
            model.hostName = name;
            loginAction(model);
        } failure:^{
            [self.view hideLoading];
            [self.view showWithError:errorForErrorCode(TOSMBSessionErrorCodeUnableToResolveAddress)];
        }];
    }
    else {
        loginAction(model);
    }
}

- (void)showAlertViewControllerWithModel:(DDPSMBInfo *)model {
    if (model == nil) {
        model = [[DDPSMBInfo alloc] init];
    }
    
    DDPSMBLoginView *view = [[DDPSMBLoginView loadNib] instantiateWithOwner:nil options:nil].firstObject;
    @weakify(self)
    view.touchLoginButtonCallBack = ^(DDPSMBLoginView *aView) {
        @strongify(self)
        if (!self) return;
        
        NSString *firstText = aView.addressTextField.text;
        if ([firstText isIpAdress]) {
            model.ipAddress = firstText;
        }
        else {
            model.hostName = firstText;
        }
        
        model.userName = aView.userNameTextField.text;
        model.password = aView.passwordTextField.text;
        model.workGroup = aView.workGroupTextField.text.length > 0 ? aView.workGroupTextField.text : @"WORKGROUP";
        [self loginWithModel:model completion:^(BOOL success) {
            if (success) {
                [aView dismiss];
            }
        }];
    };
    
    view.touchHelpButtonCallBack = ^{
        @strongify(self)
        if (!self) return;
        
        [self touchHelpButton:nil];
    };
    
    [view showAtView:self.view info:model];
}

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_add_file"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchAddButton:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_help"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchHelpButton:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemsFixedSpace:@[item, item1]];
}

- (void)touchAddButton:(UIButton *)sender {
    [self showAlertViewControllerWithModel:nil];
}

- (void)touchHelpButton:(UIButton *)sender {
    DDPHelpViewController *vc = [[DDPHelpViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchDeleteButtonWithAction:(DDPSMBInfo *)info {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[DDPCacheManager shareCacheManager] removeSMBInfo:info];
        [self.tableView reloadData];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:true completion:nil];
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 50;
        _tableView.backgroundColor = [UIColor ddp_backgroundColor];
        [_tableView registerClass:[DDPFileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"DDPFileManagerFolderPlayerListViewCell"];
        [_tableView registerClass:[DDPSMBLoginHeaderView class] forHeaderFooterViewReuseIdentifier:@"DDPSMBLoginHeaderView"];
        _tableView.tableFooterView = [[UIView alloc] init];
        
        @weakify(self)
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [self.netbiosService stopDiscovery];
            [self.nameServiceEntries removeAllObjects];
            [self.tableView reloadData];
            
            self.netbiosService = [[TONetBIOSNameService alloc] init];
            [self.netbiosService startDiscoveryWithTimeOut:4.0f added:^(TONetBIOSNameServiceEntry *entry) {
                [self.nameServiceEntries addObject:entry];
                [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
                
                LOG_INFO(DDPLogModuleFile, @"连接成功 %@", entry.name);
            } removed:^(TONetBIOSNameServiceEntry *entry) {
                [self.nameServiceEntries removeObject:entry];
                [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
                LOG_ERROR(DDPLogModuleFile, @"连接失败 %@", entry.name);
            }];
            
            [self.tableView.mj_header endRefreshing];
        }];
        
        _tableView.mj_header = header;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableArray<TONetBIOSNameServiceEntry *> *)nameServiceEntries {
    if (_nameServiceEntries == nil) {
        _nameServiceEntries = [NSMutableArray array];
    }
    return _nameServiceEntries;
}

@end
