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
#import <UITableView+FDTemplateLayoutCell.h>

@interface DDPDownloadViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DDPDownloadManagerObserver>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
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
    if (tableView.isEditing) {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    id<DDPDownloadTaskProtocol> task = [DDPDownloadManager shareDownloadManager].tasks[indexPath.row];
    if ([task isDdp_downloading]) {
        [task ddp_suspendWithCompletion:nil];
    }
    else {
        [task ddp_resumeWithCompletion:nil];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<DDPDownloadTaskProtocol> task = [DDPDownloadManager shareDownloadManager].tasks[indexPath.row];
    return [tableView fd_heightForCellWithIdentifier:DDPDownloadTableViewCell.className cacheByIndexPath:indexPath configuration:^(DDPDownloadTableViewCell *cell) {
        cell.task = task;
    }];
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
    
//    if ([task isKindOfClass:[DDPLinkDownloadTask class]]) {
//        [vc addAction:[UIAlertAction actionWithTitle:@"删除任务和源文件" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//            deleteAction(YES);
//        }]];
//    }
    
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无下载任务" attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"在\"文件\"连接\"局域网设备\"或\"我的电脑\"查看" attributes:@{NSFontAttributeName : [UIFont ddp_smallSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
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
    if (self.tableView.isEditing) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mine_download_pause"] configAction:^(UIButton *aButton) {
            [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
            [aButton setImage:[UIImage imageNamed:@"file_match_play"] forState:UIControlStateSelected];
            _rightButton = aButton;
        }];
        
        UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mine_download_delete"] configAction:^(UIButton *aButton) {
            [aButton addTarget:self action:@selector(touchDeleteItem:) forControlEvents:UIControlEventTouchUpInside];
        }];
        
        [self.navigationItem addRightItemsFixedSpace:@[item, deleteItem]];
    }
    else {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"mine_download_pause"] configAction:^(UIButton *aButton) {
            [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
            [aButton setImage:[UIImage imageNamed:@"file_match_play"] forState:UIControlStateSelected];
            _rightButton = aButton;
        }];
        
        [self.navigationItem addRightItemsFixedSpace:@[item]];
    }
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

- (void)touchDeleteItem:(UIButton *)button {
    NSArray<NSIndexPath *>*indexPathsForSelectedRows = self.tableView.indexPathsForSelectedRows;
    NSMutableArray *tasks = [NSMutableArray array];
    [indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [tasks addObject:[DDPDownloadManager shareDownloadManager].tasks[obj.row]];
    }];
    
    if (tasks.count == 0) {
        return;
    }
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认删除选择的视频吗？" preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.view showLoading];
        [[DDPDownloadManager shareDownloadManager] removeTasks:tasks force:YES completion:^{
            [self.view hideLoading];
            [self updateTableViewEditing:NO];
        }];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)updateTaskInfo {
    NSArray<NSIndexPath *> *indexPathsForVisibleRows = [self.tableView indexPathsForVisibleRows];
    [indexPathsForVisibleRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *tasks = [DDPDownloadManager shareDownloadManager].tasks;
        if (obj.row < tasks.count) {
            id<DDPDownloadTaskProtocol>task = tasks[obj.row];
            DDPDownloadTableViewCell *cell = [self.tableView cellForRowAtIndexPath:obj];
            cell.task = task;
        }
    }];
}

- (void)updateTableViewEditing:(BOOL)editing {
    [self.tableView setEditing:editing animated:YES];
    [self configRightItem];
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showEmptyView = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.emptyDataSetSource = self;
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        _tableView.allowsMultipleSelection = NO;
        [_tableView registerClass:[DDPDownloadTableViewCell class] forCellReuseIdentifier:@"DDPDownloadTableViewCell"];
        [_tableView addGestureRecognizer:self.longPressGestureRecognizer];
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

        } repeats:YES];
        _timer.fireDate = [NSDate distantFuture];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (_longPressGestureRecognizer == nil) {
        @weakify(self)
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithActionBlock:^(UILongPressGestureRecognizer * _Nonnull gesture) {
            @strongify(self)
            if (!self) return;
            
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                {
                    if (self.tableView.isEditing == NO && [DDPDownloadManager shareDownloadManager].tasks.count > 0) {
                        [self updateTableViewEditing:YES];
                        
                        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:[gesture locationInView:self.tableView]];
                        if (indexPath) {
                            //将当前长按的cell加入选择
                            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                        }
                    }
                    else {
                        [self updateTableViewEditing:NO];
                    }
                }
                    break;
                default:
                    break;
            }
        }];
    }
    return _longPressGestureRecognizer;
}

@end
