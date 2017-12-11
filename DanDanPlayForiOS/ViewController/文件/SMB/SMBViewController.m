//
//  SMBViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBViewController.h"
#import "SMBFileViewController.h"

#import "FileManagerFolderPlayerListViewCell.h"
#import "SMBLoginHeaderView.h"

#import <TOSMBClient.h>
#import "JHBaseTableView.h"
#import "NSString+Tools.h"

@interface SMBViewController ()<UITableViewDataSource, UITableViewDelegate, MGSwipeTableCellDelegate>
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) NSMutableArray <TONetBIOSNameServiceEntry *>*nameServiceEntries;
@property (strong, nonatomic) TONetBIOSNameService *netbiosService;
@end

@implementation SMBViewController

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.netbiosService stopDiscovery];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"远程设备";
    [self configRightItem];
//    self.edgesForExtendedLayout = UIRectEdgeTop | UIRectEdgeLeft | UIRectEdgeRight;
    
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
    return [CacheManager shareCacheManager].SMBInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
    if (cell.isFromCache == NO) {
        cell.titleLabel.textColor = [UIColor blackColor];
        cell.rightButtons = @[[MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor]]];
        cell.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
        cell.delegate = self;
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
        JHSMBInfo *model = [CacheManager shareCacheManager].SMBInfos[indexPath.row];
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
    
    if (([CacheManager shareCacheManager].SMBInfos.count)) {
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
        JHSMBInfo *info = [[JHSMBInfo alloc] init];
        info.hostName = entry.name;
        [self showAlertViewControllerWithModel:info];
    }
    //点击历史
    else if (indexPath.section == 1) {
        [self loginWithModel:[CacheManager shareCacheManager].SMBInfos[indexPath.row]];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        SMBLoginHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SMBLoginHeaderView"];
        view.titleLabel.text = @"本地服务器";
        return view;
    }
    
    if ([CacheManager shareCacheManager].SMBInfos.count) {
        SMBLoginHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SMBLoginHeaderView"];
        view.titleLabel.text = @"登录历史";
        return view;
    }
    
    return nil;
}

#pragma mark - MGSwipeTableCellDelegate
- (BOOL)swipeTableCell:(nonnull MGSwipeTableCell*)cell canSwipe:(MGSwipeDirection) direction {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    return indexPath.section == 1;
}

- (BOOL)swipeTableCell:(nonnull MGSwipeTableCell*)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    if (indexPath.section == 1) {
        JHSMBInfo *model = [CacheManager shareCacheManager].SMBInfos[indexPath.row];
        [[CacheManager shareCacheManager] removeSMBInfo:model];
        [self.tableView reloadData];
    }
    return YES;
}

#pragma mark - 私有方法
- (void)loginWithModel:(JHSMBInfo *)model {
    
    [MBProgressHUD showLoadingInView:self.view text:@"连接中..."];
    
    void(^loginAction)(JHSMBInfo *) = ^(JHSMBInfo *aModel) {
        [ToolsManager shareToolsManager].smbInfo = aModel;
        [[ToolsManager shareToolsManager] startDiscovererSMBFileWithParentFile:nil completion:^(JHSMBFile *file, NSError *error) {
            [MBProgressHUD hideLoading];
            
            if (error) {
                [MBProgressHUD showWithError:error atView:self.view];
                [ToolsManager shareToolsManager].smbInfo = nil;
            }
            else {
                [[CacheManager shareCacheManager] saveSMBInfo:aModel];
                [self.tableView reloadData];
                
                SMBFileViewController *vc = [[SMBFileViewController alloc] init];
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
            [MBProgressHUD hideLoading];
            [MBProgressHUD showWithError:errorForErrorCode(TOSMBSessionErrorCodeUnableToResolveAddress)];
        }];
    }
    else {
        loginAction(model);
    }
}

- (void)showAlertViewControllerWithModel:(JHSMBInfo *)model {
    if (model == nil) {
        model = [[JHSMBInfo alloc] init];
    }
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"登录SMB服务器" message:nil preferredStyle:UIAlertControllerStyleAlert];
    @weakify(vc)
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *firstText = weak_vc.textFields.firstObject.text;
        if ([firstText isIpAdress]) {
            model.ipAddress = firstText;
        }
        else {
            model.hostName = firstText;
        }
        model.userName = weak_vc.textFields[1].text;
        model.password = weak_vc.textFields[2].text;
        [self loginWithModel:model];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"服务器或ip 不区分大小写";
        textField.text = model.hostName;
        textField.font = NORMAL_SIZE_FONT;
    }];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"用户名";
        textField.font = NORMAL_SIZE_FONT;
    }];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"密码";
        textField.secureTextEntry = YES;
        textField.font = NORMAL_SIZE_FONT;
    }];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_add_file"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchAddButton:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchAddButton:(UIButton *)sender {
    [self showAlertViewControllerWithModel:nil];
}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 50;
        _tableView.backgroundColor = BACK_GROUND_COLOR;
        [_tableView registerClass:[FileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"FileManagerFolderPlayerListViewCell"];
        [_tableView registerClass:[SMBLoginHeaderView class] forHeaderFooterViewReuseIdentifier:@"SMBLoginHeaderView"];
        _tableView.tableFooterView = [[UIView alloc] init];
        
        @weakify(self)
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [self.netbiosService stopDiscovery];
            [self.nameServiceEntries removeAllObjects];
            [self.tableView reloadData];
            
            self.netbiosService = [[TONetBIOSNameService alloc] init];
            [self.netbiosService startDiscoveryWithTimeOut:4.0f added:^(TONetBIOSNameServiceEntry *entry) {
                [self.nameServiceEntries addObject:entry];
                [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
                
                NSLog(@"连接成功 %@", entry.name);
                
            } removed:^(TONetBIOSNameServiceEntry *entry) {
                [self.nameServiceEntries removeObject:entry];
                [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
                NSLog(@"连接失败 %@", entry.name);
            }];
            
            [self.tableView.mj_header endRefreshing];
        }];
        
        [header setTitle:@"下拉准备扫描（￣工￣）" forState:MJRefreshStateIdle];
        [header setTitle:@"松手扫描(￣▽￣)" forState:MJRefreshStatePulling];
        [header setTitle:@"扫描中... (　´_ゝ｀)" forState:MJRefreshStateRefreshing];
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
