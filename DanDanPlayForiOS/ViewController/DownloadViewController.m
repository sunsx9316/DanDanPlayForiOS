//
//  DownloadViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DownloadViewController.h"
#import "BaseTableView.h"
#import "DownloadTableViewCell.h"
#import "JHEdgeButton.h"

@interface DownloadViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, CacheManagerDelagate>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"下载任务";
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if ([ToolsManager shareToolsManager].SMBSession.downloadTasks.count) {
        [self.timer fire];
    }
    
    [[CacheManager shareCacheManager] addObserver:self];
    
    [self configRightItem];
}

- (void)dealloc {
    [_timer invalidate];
    [[CacheManager shareCacheManager] removeObserver:self];
}

#pragma mark - UITableViewDelegate
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TOSMBSessionDownloadTask *task = [CacheManager shareCacheManager].downloadTasks[indexPath.row];
    if (task.state == TOSMBSessionTaskStateSuspended) {
        [task resume];
        DownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell updateDataSourceWithAnimate:YES];
    }
    else if (task.state == TOSMBSessionTaskStateRunning) {
        [task suspend];
        DownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell updateDataSourceWithAnimate:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [CacheManager shareCacheManager].downloadTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TOSMBSessionDownloadTask *task = [CacheManager shareCacheManager].downloadTasks[indexPath.row];
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadTableViewCell" forIndexPath:indexPath];
    [cell setTask:task animate:NO];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确认移除这个下载吗？" message:@"删了就没了" preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        NSArray *arr = [CacheManager shareCacheManager].downloadTasks;
        if (indexPath.row < arr.count) {
            TOSMBSessionDownloadTask *task = arr[indexPath.row];
            [task cancel];
            [[CacheManager shareCacheManager] removeSMBSessionDownloadTask:task];
        }
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无下载任务" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击重试" attributes:@{NSFontAttributeName : SMALL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - CacheManagerDelagate
- (void)SMBDownloadTasksDidChange:(NSArray <TOSMBSessionDownloadTask *>*)tasks type:(SMBDownloadTasksDidChangeType)type {
    [self.tableView reloadData];
}

#pragma mark - 私有方法
- (void)configRightItem {
    JHEdgeButton *button = [[JHEdgeButton alloc] init];
    button.inset = CGSizeMake(10, 10);
    [button addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"全部暂停" forState:UIControlStateNormal];
    [button setTitle:@"全部恢复" forState:UIControlStateSelected];
    button.titleLabel.font = NORMAL_SIZE_FONT;
    [button sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)touchRightItem:(UIButton *)button {
    NSArray <TOSMBSessionDownloadTask *>*arr = [CacheManager shareCacheManager].downloadTasks;
    if (arr.count == 0) return;
    
    button.selected = !button.isSelected;
    
    if (button.isSelected) {
        [arr enumerateObjectsUsingBlock:^(TOSMBSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj suspend];
        }];
    }
    else {
        [arr enumerateObjectsUsingBlock:^(TOSMBSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj resume];
        }];
    }
    
    [self.tableView reloadData];
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 70;
        _tableView.showEmptyView = YES;
        _tableView.emptyDataSetSource = self;
        [_tableView registerClass:[DownloadTableViewCell class] forCellReuseIdentifier:@"DownloadTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [self.tableView reloadData];
            [self.tableView endRefreshing];
        }];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSTimer *)timer {
    if (_timer == nil) {
        @weakify(self)
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            if (!self) return;
            
            NSArray <DownloadTableViewCell *>*cells = [self.tableView visibleCells];
            [cells enumerateObjectsUsingBlock:^(DownloadTableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj updateDataSourceWithAnimate:YES];
            }];
            
        } repeats:YES];
    }
    return _timer;
}

@end
