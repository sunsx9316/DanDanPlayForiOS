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
#import "BaseTableView.h"

@interface SMBViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) NSMutableArray <TONetBIOSNameServiceEntry *>*nameServiceEntries;
@property (strong, nonatomic) TONetBIOSNameService *netbiosService;
@end

@implementation SMBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"浏览电脑文件";
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
    cell.titleLabel.textColor = [UIColor blackColor];
    
    if (indexPath.section == 0) {
        TONetBIOSNameServiceEntry *entry = self.nameServiceEntries[indexPath.row];
        cell.titleLabel.text = entry.name;
    }
    else {
        JHSMBInfo *model = [CacheManager shareCacheManager].SMBInfos[indexPath.row];
        cell.titleLabel.text = model.hostName;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        JHSMBInfo *model = [CacheManager shareCacheManager].SMBInfos[indexPath.row];
        [[CacheManager shareCacheManager] removeSMBInfo:model];
        [tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            TONetBIOSNameServiceEntry *entry = self.nameServiceEntries[indexPath.row];
            JHSMBInfo *info = [[JHSMBInfo alloc] init];
            info.hostName = entry.name;
            [self showAlertViewControllerWithModel:info];
        });
    }
    //点击历史
    else if (indexPath.section == 1) {
        [self loginWithModel:[CacheManager shareCacheManager].SMBInfos[indexPath.row]];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SMBLoginHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SMBLoginHeaderView"];
    if (section == 0) {
        view.titleLabel.text = @"本地服务器";
        @weakify(self)
        [view setTouchAddButtonCallback:^{
            @strongify(self)
            if (!self) return;
            
            [self showAlertViewControllerWithModel:nil];
        }];
        view.addButton.hidden = NO;
    }
    else {
        view.titleLabel.text = @"登录历史";
        view.addButton.hidden = YES;
    }
    return view;
}

#pragma mark - 私有方法
- (void)loginWithModel:(JHSMBInfo *)model {
    [ToolsManager shareToolsManager].smbInfo = model;
    [MBProgressHUD showLoadingInView:self.view text:@"连接中..."];
    [[ToolsManager shareToolsManager] startDiscovererFileWithSMBWithParentFile:nil completion:^(JHSMBFile *file, NSError *error) {
        [MBProgressHUD hideLoading];
        
        if (error) {
            [MBProgressHUD showWithText:@"连接失败"];
            [ToolsManager shareToolsManager].smbInfo = nil;
        }
        else {
            [[CacheManager shareCacheManager] saveSMBInfo:model];
            [self.tableView reloadData];
            
            SMBFileViewController *vc = [[SMBFileViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.file = file;
            vc.title = model.hostName;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)showAlertViewControllerWithModel:(JHSMBInfo *)model {
    if (model == nil) {
        model = [[JHSMBInfo alloc] init];
    }
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"登录SMB服务器" message:nil preferredStyle:UIAlertControllerStyleAlert];
    @weakify(vc)
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        model.hostName = weak_vc.textFields.firstObject.text;
        model.userName = weak_vc.textFields[1].text;
        model.password = weak_vc.textFields[2].text;
        [self loginWithModel:model];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"服务器 例如:xiaoming 不区分大小写";
        textField.text = model.hostName;
    }];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"用户名";
    }];
    
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"密码";
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 44;
        _tableView.backgroundColor = BACK_GROUND_COLOR;
        [_tableView registerClass:[FileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"FileManagerFolderPlayerListViewCell"];
        [_tableView registerClass:[SMBLoginHeaderView class] forHeaderFooterViewReuseIdentifier:@"SMBLoginHeaderView"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [self.netbiosService stopDiscovery];
            [self.nameServiceEntries removeAllObjects];
            
            self.netbiosService = [[TONetBIOSNameService alloc] init];
            [self.netbiosService startDiscoveryWithTimeOut:4.0f added:^(TONetBIOSNameServiceEntry *entry) {
                [self.nameServiceEntries addObject:entry];
                [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
            } removed:^(TONetBIOSNameServiceEntry *entry) {
                [self.nameServiceEntries removeObject:entry];
                [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
            }];
            
            [self.tableView.mj_header endRefreshing];
        }];
        
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
