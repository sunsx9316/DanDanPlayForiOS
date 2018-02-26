//
//  DDPDownloadViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDownloadViewController.h"
#import "DDPBaseTableView.h"
#import "DDPDownloadTableViewCell.h"
#import "DDPEdgeButton.h"
#import "DDPDownloadManager.h"

@interface DDPDownloadViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DDPDownloadManagerObserver>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DDPDownloadViewController
{
    __weak UIButton *_rightButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"下载任务";
    
    [self configRightItem];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if ([DDPDownloadManager shareDownloadManager].tasks.count) {
        self.timer.fireDate = [NSDate distantPast];
        NSArray <id<DDPDownloadTaskProtocol>>*arr = [DDPDownloadManager shareDownloadManager].tasks;
        __block BOOL _allTaskStatusSame = YES;
        DDPDownloadTaskState state = arr.firstObject.ddp_state;
        [arr enumerateObjectsUsingBlock:^(id<DDPDownloadTaskProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.ddp_state != state) {
                _allTaskStatusSame = YES;
            }
        }];
        
        if (_allTaskStatusSame && state != DDPDownloadTaskStateRunning) {
            _rightButton.selected = YES;
        }
    }
    
    [[DDPDownloadManager shareDownloadManager] addObserver:self];
}

- (void)dealloc {
    [_timer invalidate];
    [[DDPDownloadManager shareDownloadManager] removeObserver:self];
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
    
//    if (indexPath.section == 0) {
//        DDPLinkDownloadTask *task = self.linkDownloadTaskCollection.collection[indexPath.row];
//        JHControlLinkTaskMethod method = nil;
//        //开始
//        if (task.state == DDPLinkDownloadTaskStatePause || task.state == DDPLinkDownloadTaskStateStop || task.state == DDPLinkDownloadTaskStateError) {
//            method = JHControlLinkTaskMethodStart;
//        }
//        //暂停
//        else if (task.state == DDPLinkDownloadTaskStateDownloading) {
//            method = JHControlLinkTaskMethodPause;
//        }
//
//        if (method.length) {
//            [self.view showLoading];
//
//            [DDPLinkNetManagerOperation linkControlDownloadWithIpAdress:[DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress taskId:task.taskId method:method forceDelete:NO completionHandler:^(DDPLinkDownloadTask *responseObject, NSError *error) {
//                [MBProgressHUD hideLoadingAfterDelay:1];
//
//                if (error) {
//                    [self.view showWithError:error];
//                }
//                else {
//                    responseObject.state = [method isEqualToString:JHControlLinkTaskMethodPause] ? DDPLinkDownloadTaskStatePause : DDPLinkDownloadTaskStateDownloading;
//                    [self.linkDownloadTaskCollection.collection enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(DDPLinkDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                        if ([obj.taskId isEqualToString:responseObject.taskId]) {
//                            self.linkDownloadTaskCollection.collection[idx] = responseObject;
//                        }
//                    }];
//
//                    DDPDownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//                    [cell setTask:responseObject animate:YES];
//                }
//            }];
//        }
//    }
//    else {
//        TOSMBSessionDownloadTask *task = [DDPDownloadManager shareDownloadManager].downloadTasks[indexPath.row];
//        if (task.state == TOSMBSessionTaskStateSuspended) {
//            [task resume];
//            DDPDownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//            [cell updateDataSourceWithAnimate:YES];
//        }
//        else if (task.state == TOSMBSessionTaskStateRunning) {
//            [task suspend];
//            DDPDownloadTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//            [cell updateDataSourceWithAnimate:YES];
//        }
//    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DDPDownloadManager shareDownloadManager].tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id<DDPDownloadTaskProtocol> task = [DDPDownloadManager shareDownloadManager].tasks[indexPath.row];
    
    DDPDownloadTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPDownloadTableViewCell" forIndexPath:indexPath];
    cell.task = task;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    id<DDPDownloadTaskProtocol> task = [DDPDownloadManager shareDownloadManager].tasks[indexPath.row];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认删除这个任务吗？" preferredStyle:UIAlertControllerStyleAlert];
    
    void(^deleteAction)(BOOL) = ^(BOOL flag) {
        [self.view showLoading];
        [[DDPDownloadManager shareDownloadManager] removeTask:task force:flag completion:^(NSError *error) {
            [self.view hideLoading];
            
            if (error) {
                [self.view showWithError:error];
            }
        }];
    };
    
    [vc addAction:[UIAlertAction actionWithTitle:@"删除任务" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        deleteAction(NO);
    }]];
    
    if ([task isKindOfClass:[DDPLinkDownloadTask class]]) {
        [vc addAction:[UIAlertAction actionWithTitle:@"删除任务和源文件" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            deleteAction(YES);
        }]];
    }
    
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无下载任务" attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"在\"文件\"连接\"远程设备\"或\"我的电脑\"查看" attributes:@{NSFontAttributeName : [UIFont ddp_smallSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - DDPDownloadManagerObserver
- (void)tasksDidChange:(NSArray <id<DDPDownloadTaskProtocol>>*)tasks
                  type:(DDPDownloadTasksChangeType)type
                 error:(NSError *)error {
    [self.tableView reloadData];
}

#pragma mark - 私有方法
- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mine_download_pause"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
        [aButton setImage:[UIImage imageNamed:@"file_match_play"] forState:UIControlStateSelected];
        _rightButton = aButton;
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)button {
    
    NSArray <id<DDPDownloadTaskProtocol>>*arr = [DDPDownloadManager shareDownloadManager].tasks;
    if (arr.count == 0) return;
    
    button.selected = !button.isSelected;
    
    if (button.isSelected) {
        [arr enumerateObjectsUsingBlock:^(id<DDPDownloadTaskProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[DDPDownloadManager shareDownloadManager] pauseTask:obj completion:nil];
        }];
    }
    else {
        [arr enumerateObjectsUsingBlock:^(id<DDPDownloadTaskProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[DDPDownloadManager shareDownloadManager] resumeTask:obj completion:nil];
        }];
    }
    
    [self.tableView reloadData];
}

- (void)updateTaskInfo {
    NSArray<NSIndexPath *> *indexPathsForVisibleRows = [self.tableView indexPathsForVisibleRows];
    [indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id<DDPDownloadTaskProtocol>task = [DDPDownloadManager shareDownloadManager].tasks[obj.row];
        DDPDownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:obj];
        cell.task = task;
    }];
    
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 70;
        _tableView.showEmptyView = YES;
        _tableView.emptyDataSetSource = self;
        [_tableView registerClass:[DDPDownloadTableViewCell class] forCellReuseIdentifier:@"DDPDownloadTableViewCell"];
//        [_tableView registerClass:[DDPTextHeaderView class] forHeaderFooterViewReuseIdentifier:@"DDPTextHeaderView"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
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
            
            [self updateTaskInfo];
//            DDPLinkInfo *info = [DDPCacheManager shareCacheManager].linkInfo;
//            if (info) {
//                [DDPLinkNetManagerOperation linkDownloadListWithIpAdress:info.selectedIpAdress completionHandler:^(DDPLinkDownloadTaskCollection *responseObject, NSError *error) {
//                    if (error == nil) {
//                        if (responseObject.collection.count > 0 && [DDPCacheManager shareCacheManager].timerIsStart == NO) {
//                            [[DDPCacheManager shareCacheManager] addLinkDownload];
//                        }
//
//                        NSInteger oldCount = self.linkDownloadTaskCollection.collection.count;
//                        NSInteger aNewCount = responseObject.collection.count;
//
//                        self.linkDownloadTaskCollection = responseObject;
//                        if (oldCount != aNewCount) {
//                            [self.tableView reloadData];
//                            [self.tableView reloadEmptyDataSet];
//                        }
//
//                        NSArray <NSIndexPath *>*indexPaths = [self.tableView indexPathsForVisibleRows];
//                        [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                            DDPDownloadLinkTableViewCell *cell = [self.tableView cellForRowAtIndexPath:obj];
//                            if (obj.section == 0) {
//                                //                                [cell updateDataSourceWithAnimate:YES];
//                                [cell setTask:self.linkDownloadTaskCollection.collection[obj.row] animate:YES];
//                            }
//                        }];
//                    }
//                }];
//            }
//
//            NSArray <NSIndexPath *>*indexPaths = [self.tableView indexPathsForVisibleRows];
//            [indexPaths enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                DDPDownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:obj];
//                if (obj.section != 0) {
//                    [cell updateDataSourceWithAnimate:YES];
//                }
//            }];

        } repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
