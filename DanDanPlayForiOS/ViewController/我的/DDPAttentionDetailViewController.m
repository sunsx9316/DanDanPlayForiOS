//
//  DDPAttentionDetailViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPAttentionDetailViewController.h"
#import "DDPHomePageSearchViewController.h"
#import "DDPLinkFileManagerViewController.h"
#import "DDPPlayNavigationController.h"
#import "DDPMatchViewController.h"

#import "DDPBaseTableView.h"
#import "DDPAttentionDetailTableViewCell.h"
#import "DDPAttentionDetailHistoryTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "NSDate+Tools.h"
#import "DDPEdgeButton.h"

@interface DDPAttentionDetailViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) DDPPlayHistory *historyModel;

/**
 根目录文件
 */
@property (strong, nonatomic) DDPLinkFile *rootLinkFile;
@end

@implementation DDPAttentionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"番剧详情";
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return !!self.historyModel;
    }
    return self.historyModel.collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    @weakify(self)
    if (indexPath.section == 0) {
        DDPAttentionDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DDPAttentionDetailTableViewCell.className forIndexPath:indexPath];
        cell.model = self.historyModel;
        cell.touchSearchButtonCallBack = ^(DDPPlayHistory *aModel) {
            @strongify(self)
            if (!self) return;
            
            DDPHomePageSearchViewController *vc = [[DDPHomePageSearchViewController alloc] init];
            DDPDMHYSearchConfig *config = [[DDPDMHYSearchConfig alloc] init];
            vc.config = config;
            config.keyword = self.historyModel.searchKeyword.length ? self.historyModel.searchKeyword : self.historyModel.name;
            [self.navigationController pushViewController:vc animated:YES];
        };
        return cell;
    }
    
    DDPAttentionDetailHistoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DDPAttentionDetailHistoryTableViewCell.className forIndexPath:indexPath];
    cell.model = self.historyModel.collection[indexPath.row];
    cell.touchPlayButtonCallBack = ^(DDPLinkFile *file) {
        @strongify(self)
        if (!self) return;
        
        DDPVideoModel *model = file.videoModel;
        void(^jumpToMatchVCAction)(void) = ^{
            DDPMatchViewController *vc = [[DDPMatchViewController alloc] init];
            vc.model = model;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        if ([DDPCacheManager shareCacheManager].openFastMatch) {
            MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
            [DDPMatchNetManagerOperation fastMatchVideoModel:model progressHandler:^(float progress) {
                aHUD.progress = progress;
                aHUD.label.text = ddp_danmakusProgressToString(progress);
            } completionHandler:^(DDPDanmakuCollection *responseObject, NSError *error) {
                model.danmakus = responseObject;
                [aHUD hideAnimated:NO];
                
                if (responseObject == nil) {
                    jumpToMatchVCAction();
                }
                else {
                    DDPPlayNavigationController *nav = [[DDPPlayNavigationController alloc] initWithModel:model];
                    [self presentViewController:nav animated:YES completion:nil];
                }
            }];
        }
        else {
            jumpToMatchVCAction();
        }
    };
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return DETAIL_CELL_HEIGHT + 40;
    }
    
    return [tableView fd_heightForCellWithIdentifier:@"DDPAttentionDetailHistoryTableViewCell" cacheByIndexPath:indexPath configuration:^(DDPAttentionDetailHistoryTableViewCell *cell) {
        cell.model = self.historyModel.collection[indexPath.row];
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != 0) {
        //未登录
        if ([DDPCacheManager shareCacheManager].user == nil) {
            [[DDPToolsManager shareToolsManager] popLoginAlertViewInViewController:self];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            DDPEpisode *model = self.historyModel.collection[indexPath.row];
            //已观看
            if (model.time.length != 0) return;
            
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"是否标记为已看过？" message:@"将会自动关注这个动画" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self.view showLoadingWithText:@"添加中..."];
                [DDPFavoriteNetManagerOperation favoriteAddHistoryWithUser:[DDPCacheManager shareCacheManager].user episodeId:model.identity addToFavorite:YES completionHandler:^(NSError *error) {
                    [self.view hideLoading];
                    
                    if (error) {
                        [self.view showWithError:error];
                    }
                    else {
                        model.time = [NSDate historyTimeStyleWithDate:[NSDate date]];
                        if (self.attentionCallBack) {
                            self.attentionCallBack(self.animateId);
                        }
                        [self.tableView reloadData];
                    }
                }];
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    if (offset > DETAIL_CELL_HEIGHT + 40) {
        self.navigationItem.title = self.historyModel.name;
    }
    else {
        self.navigationItem.title = @"番剧详情";
    }
}

#pragma mark - 私有方法

- (void)requestLibrary {
    DDPLinkInfo *linkInfo = [DDPCacheManager shareCacheManager].linkInfo ? [DDPCacheManager shareCacheManager].linkInfo : [DDPCacheManager shareCacheManager].lastLinkInfo;
    
    [[DDPToolsManager shareToolsManager] startDiscovererFileWithLinkParentFile:nil linkInfo:linkInfo completion:^(DDPLinkFile *file, NSError *error) {
        if (error && error.code != DDPErrorCodeParameterNoCompletion) {
//            [self.view showWithError:error];
        }
        else {
            self.rootLinkFile = file;
            
            NSMutableArray <DDPLinkFile *>*tempArr = [NSMutableArray array];
            if (file.subFiles.count) {
                [tempArr addObjectsFromArray:file.subFiles];
            }
            
            [tempArr enumerateObjectsUsingBlock:^(DDPLinkFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.type == DDPFileTypeFolder) {
                    if (obj.subFiles.count) {
                        [tempArr addObjectsFromArray:obj.subFiles];
                    }
                }
                else {
                    [self.historyModel.collection enumerateObjectsUsingBlock:^(DDPEpisode * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
                        if (obj1.identity == obj.library.episodeId) {
                            obj1.linkFile = obj;
                        }
                    }];
                }
            }];
            
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[DDPAttentionDetailTableViewCell class] forCellReuseIdentifier:DDPAttentionDetailTableViewCell.className];
        [_tableView registerClass:[DDPAttentionDetailHistoryTableViewCell class] forCellReuseIdentifier:DDPAttentionDetailHistoryTableViewCell.className];
        
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [DDPFavoriteNetManagerOperation favoriteHistoryAnimateWithUser:[DDPCacheManager shareCacheManager].user animateId:self.animateId completionHandler:^(DDPPlayHistory *responseObject, NSError *error) {
                if (error) {
                    [self.view showWithError:error];
                }
                else {
                    self.historyModel = responseObject;
                    self.historyModel.isOnAir = self.isOnAir;
                    [self requestLibrary];
                    [self.tableView reloadData];
                }
                
                
                [self.tableView endRefreshing];
            }];
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
