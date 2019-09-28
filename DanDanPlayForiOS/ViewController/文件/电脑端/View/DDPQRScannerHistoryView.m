//
//  DDPQRScannerHistoryView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPQRScannerHistoryView.h"
#import "DDPBaseTableView.h"
#import "DDPCacheManager+multiply.h"
#import "DDPQRScannerHistoryTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "UIView+Tools.h"

//static char alertViewValueKey = 0;

@interface DDPQRScannerHistoryView ()<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet DDPBaseTableView *tableView;

@end

@implementation DDPQRScannerHistoryView
{
    __weak DDPLinkInfo *_selectedInfo;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.tableView registerNib:[DDPQRScannerHistoryTableViewCell loadNib] forCellReuseIdentifier:DDPQRScannerHistoryTableViewCell.className];
    self.tableView.layer.cornerRadius = 6;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.tableFooterView = [[UIView alloc] init];
    @weakify(self)
    self.tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
        @strongify(self)
        if (!self) return;
        
        [self.tableView reloadData];
        [self.tableView endRefreshing];
    }];
    
    self.alpha = 0;
}

- (void)show {
    if (self.tableView.mj_header.refreshingBlock) {
        self.tableView.mj_header.refreshingBlock();
    }
    
    [self ddp_showViewWithHolderView:self.tableView completion:nil];
}

- (IBAction)dismiss {
    [self ddp_dismissViewWithCompletion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DDPCacheManager shareCacheManager].linkInfoHistorys.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPLinkInfo *info = [DDPCacheManager shareCacheManager].linkInfoHistorys[indexPath.row];
    DDPQRScannerHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DDPQRScannerHistoryTableViewCell.className forIndexPath:indexPath];
    cell.model = info;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPLinkInfo *info = [DDPCacheManager shareCacheManager].linkInfoHistorys[indexPath.row];
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定删除吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    _selectedInfo = info;
    [view show];
    #pragma clang diagnostic pop
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DDPLinkInfo *info = [DDPCacheManager shareCacheManager].linkInfoHistorys[indexPath.row];
    if (self.selectedInfoCallBack) {
        self.selectedInfoCallBack(info);
    }
    
    [self dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPLinkInfo *info = [DDPCacheManager shareCacheManager].linkInfoHistorys[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:DDPQRScannerHistoryTableViewCell.className configuration:^(DDPQRScannerHistoryTableViewCell *cell) {
        cell.model = info;
    }];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - UIAlertViewDelegate

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[DDPCacheManager shareCacheManager] removeLinkInfo:_selectedInfo];
    [self.tableView reloadData];
}
#pragma clang diagnostic pop
@end
