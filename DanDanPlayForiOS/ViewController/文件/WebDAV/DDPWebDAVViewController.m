//
//  DDPWebDAVViewController.m
//  DDPlay
//
//  Created by JimHuang on 2020/4/26.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPWebDAVViewController.h"
#import "DDPWebDAVFileViewController.h"
#import "DDPBaseTableView.h"
#import "DDPFileManagerFolderPlayerListViewCell.h"
#import "DDPSMBLoginHeaderView.h"
#import "DDPSMBLoginView.h"
#import "DDPWebDAVLoginInfo+Tools.h"

@interface DDPWebDAVViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@end

@implementation DDPWebDAVViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"WebDAV服务器";
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DDPCacheManager shareCacheManager].webDAVInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPFileManagerFolderPlayerListViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerFolderPlayerListViewCell" forIndexPath:indexPath];
    if (cell.isFromCache == NO) {
        cell.titleLabel.textColor = [UIColor blackColor];
        [cell.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(15);
            make.bottom.mas_offset(-15);
        }];
        cell.fromCache = YES;
    }
    
    let model = [DDPCacheManager shareCacheManager].webDAVInfos[indexPath.row];
    cell.titleLabel.text = model.url.host;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    let model = [DDPCacheManager shareCacheManager].webDAVInfos[indexPath.row];
    [self loginWithModel:model completion:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDPSMBLoginHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDPSMBLoginHeaderView"];
    view.titleLabel.text = @"登录历史";
    return view;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @[^{
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull aIndexPath) {
            let model = [DDPCacheManager shareCacheManager].webDAVInfos[aIndexPath.row];
            [self touchDeleteButtonWithAction:model];
        }];
        action.backgroundColor = DDPRGBColor(255, 48, 54);
        return action;
    }()];
}

#pragma mark - 私有方法
- (void)loginWithModel:(DDPWebDAVLoginInfo *)model completion:(void(^)(BOOL success))completion {
    
    [self.view showLoadingWithText:@"连接中..."];
    
    [DDPToolsManager shareToolsManager].webDAVLoginInfo = model;
    [[DDPToolsManager shareToolsManager] startDiscovererWebDevFileWithParentFile:nil completion:^(DDPWebDAVFile *aFile, NSError *error) {
        [self.view hideLoading];

        if (completion) {
            completion(error == nil);
        }

        if (error) {
            [self.view showWithError:error];
            [DDPToolsManager shareToolsManager].webDAVLoginInfo = nil;
        }
        else {
            [[DDPCacheManager shareCacheManager] saveWebDAVInfo:model];
            [self.tableView reloadData];

            DDPWebDAVFileViewController *vc = [[DDPWebDAVFileViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.file = aFile;
            vc.title = model.itemHostName;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
}

- (void)showAlertViewControllerWithModel:(DDPWebDAVLoginInfo *)model {
    if (model == nil) {
        model = [[DDPWebDAVLoginInfo alloc] init];
    }
    
    DDPSMBLoginView *view = [[DDPSMBLoginView loadNib] instantiateWithOwner:nil options:nil].firstObject;
    [view.workGroupTextField removeFromSuperview];
    view.helpButton.hidden = YES;
    view.titleLabel.text = @"登陆 WebDAV 服务器";
    view.addressTextField.placeholder = @"服务器地址";
    @weakify(self)
    view.touchLoginButtonCallBack = ^(DDPSMBLoginView *aView) {
        @strongify(self)
        if (!self) return;
        
        NSString *firstText = [aView.addressTextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        model.path = firstText;
        
        model.userName = aView.userNameTextField.text;
        model.userPassword = aView.passwordTextField.text;
        [self loginWithModel:model completion:^(BOOL success) {
            if (success) {
                [aView dismiss];
            }
        }];
    };
    
    [view showAtView:self.view info:model];
}

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_add_file"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchAddButton:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemsFixedSpace:@[item]];
}

- (void)touchAddButton:(UIButton *)sender {
    [self showAlertViewControllerWithModel:nil];
}

- (void)touchDeleteButtonWithAction:(DDPWebDAVLoginInfo *)info {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[DDPCacheManager shareCacheManager] removeWebDAVInfo:info];
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
            
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }];
        
        _tableView.mj_header = header;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
