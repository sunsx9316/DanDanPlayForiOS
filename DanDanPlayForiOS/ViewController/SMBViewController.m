//
//  SMBViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBViewController.h"
#import "SMBFileViewController.h"

#import "SMBInputTableViewCell.h"
#import "FileManagerFolderPlayerListViewCell.h"
#import "SMBLoginTableViewCell.h"
#import "SMBLoginHeaderView.h"

#import <TOSMBClient.h>

@interface SMBViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation SMBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"浏览电脑文件";
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    }
    return [CacheManager shareCacheManager].SMBInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            SMBLoginTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SMBLoginTableViewCell" forIndexPath:indexPath];
            return cell;
        }
        
        SMBInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SMBInputTableViewCell" forIndexPath:indexPath];
        cell.textField.secureTextEntry = NO;
        if (indexPath.row == 0) {
            cell.textField.placeholder = @"服务器 例如:xiaoming 不区分大小写";
        }
        else if (indexPath.row == 1) {
            cell.textField.placeholder = @"用户名";
        }
        else {
            cell.textField.placeholder = @"密码";
            cell.textField.secureTextEntry = YES;
        }
        return cell;
    }
    
    FileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
    cell.titleLabel.textColor = [UIColor blackColor];
    JHSMBInfo *model = [CacheManager shareCacheManager].SMBInfos[indexPath.row];
    cell.titleLabel.text = model.hostName;
    
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
    if (indexPath.section == 0) {
        return 44 + (44 * jh_isPad());
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 25;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 3) {
        SMBInputTableViewCell *hostCell = (SMBInputTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        NSString *hostName = hostCell.textField.text;
        if (hostName.length == 0) {
            [MBProgressHUD showWithText:@"请输入服务器名称！"];
            return;
        }
        
        SMBInputTableViewCell *userNameCell = (SMBInputTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        NSString *userName = userNameCell.textField.text;
        
        SMBInputTableViewCell *userPasswordCell = (SMBInputTableViewCell *)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
        NSString *password = userPasswordCell.textField.text;
        
        
        JHSMBInfo *_model = [[JHSMBInfo alloc] init];
        _model.userName = userName;
        _model.password = password;
        _model.hostName = hostName;
        
        [self loginWithModel:_model];
    }
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
    if (section == 0) {
        return nil;
    }
    
    SMBLoginHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SMBLoginHeaderView"];
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

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 44;
        _tableView.backgroundColor = BACK_GROUND_COLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[SMBInputTableViewCell class] forCellReuseIdentifier:@"SMBInputTableViewCell"];
        [_tableView registerClass:[FileManagerFolderPlayerListViewCell class] forCellReuseIdentifier:@"FileManagerFolderPlayerListViewCell"];
        [_tableView registerClass:[SMBLoginTableViewCell class] forCellReuseIdentifier:@"SMBLoginTableViewCell"];
        [_tableView registerClass:[SMBLoginHeaderView class] forHeaderFooterViewReuseIdentifier:@"SMBLoginHeaderView"];
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
