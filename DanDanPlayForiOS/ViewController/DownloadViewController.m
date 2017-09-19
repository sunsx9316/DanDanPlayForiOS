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
#import "DownloadLinkTableViewCell.h"
#import "JHEdgeButton.h"
#import "SMBLoginHeaderView.h"

@interface DownloadViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, CacheManagerDelagate>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) JHLinkDownloadTaskCollection *linkDownloadTaskCollection;
@end

@implementation DownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"下载任务";
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if ([CacheManager shareCacheManager].downloadTasks.count || [CacheManager shareCacheManager].linkInfo) {
        self.timer.fireDate = [NSDate distantPast];
    }
    
    [[CacheManager shareCacheManager] addObserver:self];
    [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"linkDownloadingTaskCount" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self configRightItem];
}

- (void)dealloc {
    [_timer invalidate];
    [[CacheManager shareCacheManager] removeObserver:self];
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"linkDownloadingTaskCount"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"linkDownloadingTaskCount"]) {
        NSNumber *aOldValue = change[NSKeyValueChangeOldKey];
        NSNumber *aNewValue = change[NSKeyValueChangeNewKey];
        if ([aOldValue isEqual:aNewValue] == NO) {
            [self.tableView reloadData];
        }
    }
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
    
    if (indexPath.section == 0) {
        JHLinkDownloadTask *task = self.linkDownloadTaskCollection.collection[indexPath.row];
        [MBProgressHUD showLoadingInView:self.view text:nil];
        JHControlLinkTaskMethod method = nil;
        //开始
        if (task.state == JHLinkDownloadTaskStatePause || task.state == JHLinkDownloadTaskStateStop || task.state == JHLinkDownloadTaskStateError) {
            method = JHControlLinkTaskMethodStart;
        }
        //暂停
        else if (task.state == JHLinkDownloadTaskStateDownloading) {
            method = JHControlLinkTaskMethodPause;
        }
        
        if (method.length) {
            [LinkNetManager linkControlDownloadWithIpAdress:[CacheManager shareCacheManager].linkInfo.selectedIpAdress taskId:task.taskId method:method forceDelete:NO completionHandler:^(JHLinkDownloadTask *responseObject, NSError *error) {
                [MBProgressHUD hideLoadingAfterDelay:1];
                
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
                    responseObject.state = [method isEqualToString:JHControlLinkTaskMethodPause] ? JHLinkDownloadTaskStatePause : JHLinkDownloadTaskStateDownloading;
                    [self.linkDownloadTaskCollection.collection enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(JHLinkDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.taskId isEqualToString:responseObject.taskId]) {
                            self.linkDownloadTaskCollection.collection[idx] = responseObject;
                        }
                    }];
                    
                    DownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    [cell setTask:responseObject animate:YES];
                }
            }];
        }
    }
    else {
        TOSMBSessionDownloadTask *task = [CacheManager shareCacheManager].downloadTasks[indexPath.row];
        if (task.state == TOSMBSessionDownloadTaskStateSuspended) {
            [task resume];
            DownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell updateDataSourceWithAnimate:YES];
        }
        else if (task.state == TOSMBSessionDownloadTaskStateRunning) {
            [task suspend];
            DownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            [cell updateDataSourceWithAnimate:YES];
        }
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SMBLoginHeaderView *headView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SMBLoginHeaderView"];
    headView.addButton.hidden = YES;
    if (section == 0) {
        headView.titleLabel.text = @"电脑端任务";
    }
    else {
        headView.titleLabel.text = @"远程设备任务";
    }
    return headView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.linkDownloadTaskCollection.collection.count;
    }
    return [CacheManager shareCacheManager].downloadTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DownloadLinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadLinkTableViewCell" forIndexPath:indexPath];
        JHLinkDownloadTask *task = self.linkDownloadTaskCollection.collection[indexPath.row];
        [cell setTask:task animate:NO];
        return cell;
    }
    
    TOSMBSessionDownloadTask *task = [CacheManager shareCacheManager].downloadTasks[indexPath.row];
    DownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadTableViewCell" forIndexPath:indexPath];
    [cell setTask:task animate:NO];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"确认移除这个下载吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        JHLinkDownloadTask *task = self.linkDownloadTaskCollection.collection[indexPath.row];
        void(^deleteAction)(BOOL) = ^(BOOL flag) {
            [MBProgressHUD showLoadingInView:self.view text:nil];
            [LinkNetManager linkControlDownloadWithIpAdress:[CacheManager shareCacheManager].linkInfo.selectedIpAdress taskId:task.taskId method:JHControlLinkTaskMethodDelete forceDelete:flag completionHandler:^(JHLinkDownloadTask *responseObject, NSError *error) {
                [MBProgressHUD hideLoading];
                
                if (error) {
                    [MBProgressHUD showWithError:error];
                }
                else {
                    [self.linkDownloadTaskCollection.collection removeObject:task];
                    [self.tableView reloadData];                    
                }
            }];
        };
        
        [vc addAction:[UIAlertAction actionWithTitle:@"删除任务" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            deleteAction(NO);
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"删除任务和源文件" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            deleteAction(YES);
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
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
        [_tableView registerClass:[DownloadLinkTableViewCell class] forCellReuseIdentifier:@"DownloadLinkTableViewCell"];
        [_tableView registerClass:[SMBLoginHeaderView class] forHeaderFooterViewReuseIdentifier:@"SMBLoginHeaderView"];
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
        _timer = [NSTimer timerWithTimeInterval:1.0 block:^(NSTimer * _Nonnull timer) {
            @strongify(self)
            if (!self) return;
            
            JHLinkInfo *info = [CacheManager shareCacheManager].linkInfo;
            if (info) {
                [LinkNetManager linkDownloadListWithIpAdress:info.selectedIpAdress completionHandler:^(JHLinkDownloadTaskCollection *responseObject, NSError *error) {
                    if (error == nil) {
                        NSInteger oldCount = self.linkDownloadTaskCollection.collection.count;
                        NSInteger aNewCount = responseObject.collection.count;
                        
                        self.linkDownloadTaskCollection = responseObject;
                        if (oldCount != aNewCount) {
                            [self.tableView reloadData];
                            [self.tableView reloadEmptyDataSet];
                        }
                        
                        NSArray <NSIndexPath *>*indexPaths = [self.tableView indexPathsForVisibleRows];
                        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            DownloadLinkTableViewCell *cell = [self.tableView cellForRowAtIndexPath:obj];
                            if (obj.section == 0) {
                                //                                [cell updateDataSourceWithAnimate:YES];
                                [cell setTask:self.linkDownloadTaskCollection.collection[obj.row] animate:YES];
                            }
                        }];
                    }
                }];
            }
            
            NSArray <NSIndexPath *>*indexPaths = [self.tableView indexPathsForVisibleRows];
            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:obj];
                if (obj.section != 0) {
                    [cell updateDataSourceWithAnimate:YES];
                }
            }];
            
        } repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
