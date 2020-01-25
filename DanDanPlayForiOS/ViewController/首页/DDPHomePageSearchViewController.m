//
//  DDPHomePageSearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHomePageSearchViewController.h"
#import "DDPQRScannerViewController.h"
#import "DDPBaseWebViewController.h"
#import "DDPDownloadViewController.h"

#import "DDPBaseTableView.h"
#import "HomePageSearchTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "HomePageSearchFilterView.h"
#import "DDPEdgeButton.h"
#import "DDPExpandView.h"
#import "DDPSearchBar.h"
#import "HomePageSearchFilterModel.h"
#import "DDPCommentNetManagerOperation.h"

@interface DDPHomePageSearchViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, HomePageSearchFilterViewDelegate, HomePageSearchFilterViewDataSource>
//@property (strong, nonatomic) DDPSearchBar *searchBar;
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) DDPDMHYSearchCollection *collection;
@property (strong, nonatomic) HomePageSearchFilterView *filterView;
@property (strong, nonatomic) NSArray <DDPDMHYSearch *>*dataSource;
@property (strong, nonatomic) NSArray <HomePageSearchFilterModel *>*filterDataSource;
@end

@implementation DDPHomePageSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRightItem];
//    [self configTitleView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(FILTER_VIEW_HEIGHT);
    }];
    
    if (self.config.keyword.length > 0) {
//        self.searchBar.text = self.config.keyword;
        [self.tableView.mj_header beginRefreshing];
    }
    else {
        [self.tableView endRefreshing];
    }
}

- (void)setConfig:(DDPDMHYSearchConfig *)config {
    _config = config;
    
    if (self.isViewLoaded) {
        [self.tableView.mj_header beginRefreshing];
//        [self.tableView.mj_header beginRefreshing];
    }
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    if (self.config == nil) {
//        [UIView performWithoutAnimation:^{
//            [self.searchBar becomeFirstResponder];
//        }];
//    }
//}

//#pragma mark - UISearchBarDelegate
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    DDPDMHYSearchConfig *config = [[DDPDMHYSearchConfig alloc] init];
//    config.keyword = searchBar.text;
//    self.config = config;
//    [self.tableView.mj_header beginRefreshing];
//    [searchBar endEditing:YES];
//}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomePageSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageSearchTableViewCell" forIndexPath:indexPath];
    cell.model = _dataSource[indexPath.row];
    @weakify(self)
    cell.touchSubGroupCallBack = ^(DDPDMHYSearch *aModel) {
        @strongify(self)
        if (!self) return;
        
        DDPHomePageSearchViewController *vc = [[DDPHomePageSearchViewController alloc] init];
        DDPDMHYSearchConfig *config = [[DDPDMHYSearchConfig alloc] init];
        config.subGroupId = aModel.subgroupId;
        vc.config = config;
        [self.navigationController pushViewController:vc animated:YES];
    };
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    let model = self.dataSource[indexPath.row];
    [self downloadVideoWithMagnet:model.magnet pageUrl:model.pageUrl];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"HomePageSearchTableViewCell" cacheByIndexPath:indexPath configuration:^(HomePageSearchTableViewCell *cell) {
        cell.model = self.dataSource[indexPath.row];
    }];
}

#pragma mark - HomePageSearchFilterViewDataSource
- (NSInteger)numberOfSection {
    return self.filterDataSource.count;
}

- (NSInteger)numberOfItemAtSection:(NSInteger)section {
    return self.filterDataSource[section].subItems.count;
}

- (NSString *)itemTitleAtIndexPath:(NSIndexPath *)indexPath {
    return self.filterDataSource[indexPath.section].subItems[indexPath.row];
}


//- (NSInteger)numberOfItem {
//    return self.filterDataSource.count;
//}
//
//- (NSString *)itemTitleAtSection:(NSInteger)index {
//    return self.filterDataSource[index].title;
//}
//
//- (NSInteger)numberOfSubItemAtSection:(NSInteger)index {
//    return self.filterDataSource[index].subItems.count;
//}
//
//- (NSString *)subItemTitleAtIndex:(NSInteger)index section:(NSInteger)section {
//    return self.filterDataSource[section].subItems[index];
//}

#pragma mark - HomePageSearchFilterViewDelegate
- (void)pageSearchFilterView:(HomePageSearchFilterView *)view
  didSelectedItemAtIndexPath:(NSIndexPath *)indexPath
                       title:(NSString *)title {
    self.filterDataSource[indexPath.section].title = title;
    
    NSInteger typeIndex = [view selectedItemIndexAtSection:0];
    NSInteger subGroupIndex = [view selectedItemIndexAtSection:1];
    
    NSString *type = self.filterDataSource[0].subItems[typeIndex];
    NSString *subGroup = self.filterDataSource[1].subItems[subGroupIndex];
    
    //啥也没选
    if (typeIndex == 0 && subGroupIndex == 0) {
        self.dataSource = self.collection.collection;
    }
    else {
        NSMutableArray *tempArr = [NSMutableArray array];
        [self.collection.collection enumerateObjectsUsingBlock:^(DDPDMHYSearch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ((typeIndex == 0 || [obj.typeName isEqualToString:type]) && (subGroupIndex == 0 || [obj.subgroupName isEqualToString:subGroup])) {
                [tempArr addObject:obj];
            }
        }];
        self.dataSource = tempArr;
    }
    
    [self.tableView reloadData];
    [self.tableView reloadEmptyDataSet];
}

- (CGFloat)widthAtSection:(NSInteger)section {
    NSInteger width = (NSInteger)(kScreenWidth / self.filterDataSource.count);
    return width;
}

#pragma mark - 私有方法
- (void)downloadVideoWithMagnet:(NSString *)magnet pageUrl:(NSURL *)pageUrl {
    
    if (ddp_appType == DDPAppTypeToMac) {
        if (pageUrl) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"选择操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"查看下载页面" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [UIApplication.sharedApplication openURL:pageUrl options:@{} completionHandler:nil];
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"使用软件下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [UIPasteboard generalPasteboard].string = magnet;
                
                NSURL *aURL = [NSURL URLWithString:magnet];
                [UIApplication.sharedApplication openURL:aURL options:@{} completionHandler:nil];
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:vc animated:YES completion:nil];
        } else {
            [UIPasteboard generalPasteboard].string = magnet;
            
            NSURL *aURL = [NSURL URLWithString:magnet];
            [UIApplication.sharedApplication openURL:aURL options:@{} completionHandler:nil];
        }
        
    } else {
        if (magnet.length == 0) return;
        
        @weakify(self)
        void(^downloadAction)(NSString *magnet) = ^(NSString *magnet){
            @strongify(self)
            if (!self) return;
            
            [self.view showLoadingWithText:@"创建下载任务中..."];
            [DDPLinkNetManagerOperation linkAddDownloadWithIpAdress:[DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress magnet:magnet completionHandler:^(DDPLinkDownloadTask *responseObject, NSError *error) {
                @strongify(self)
                if (!self) return;
                
                [self.view hideLoading];
                
                if (error) {
                    [self.view showWithError:error];
                }
                else {
                    [[DDPDownloadManager shareDownloadManager] startObserverTaskInfo];
                    
                    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"创建下载任务成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    [vc addAction:[UIAlertAction actionWithTitle:@"下载列表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        DDPDownloadViewController *vc = [[DDPDownloadViewController alloc] init];
                        [self.navigationController pushViewController:vc animated:YES];
                    }]];
                    
                    [vc addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:nil]];
                    
                    [self presentViewController:vc animated:YES completion:nil];
                }
            }];
        };
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"选择操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"复制磁力链" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [UIPasteboard generalPasteboard].string = magnet;
            [self.view showWithText:@"复制成功"];
        }]];
        
        if (pageUrl) {
            [vc addAction:[UIAlertAction actionWithTitle:@"查看下载页面" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithURL:pageUrl];
                @weakify(self)
                vc.clickMagnetCallBack = ^(NSString *url) {
                    @strongify(self)
                    if (!self) return;
                    
                    [self downloadVideoWithMagnet:url];
                };
                [self.navigationController pushViewController:vc animated:YES];
                
            }]];
        }
        
        [vc addAction:[UIAlertAction actionWithTitle:@"使用电脑端下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([DDPCacheManager shareCacheManager].linkInfo == nil) {
                DDPQRScannerViewController *vc = [[DDPQRScannerViewController alloc] init];
                @weakify(self)
                vc.linkSuccessCallBack = ^(DDPLinkInfo *info) {
                    @strongify(self)
                    if (!self) return;
                    
                    downloadAction(magnet);
                    [self.navigationController popViewControllerAnimated:YES];
                };
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                downloadAction(magnet);
            }
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)downloadVideoWithMagnet:(NSString *)magnet {
    [self downloadVideoWithMagnet:magnet pageUrl:nil];
}

//- (void)configRightItem {
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_browser"] configAction:^(UIButton *aButton) {
//        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
//        aButton.userInteractionEnabled = !!self.config;
//    }];
//    
//    [self.navigationItem addRightItemFixedSpace:item];
//}
//
//- (void)touchRightItem:(UIButton *)sender {
//    
//    NSString *link = self.config.link;
//    if (link.length == 0) {
//        link = [NSString stringWithFormat:@"https://share.dmhy.org/topics/list?keyword=%@", [self.config.keyword stringByURLEncode]];
//    }
//    
////    [self.searchBar resignFirstResponder];
//    
//    DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithURL:[NSURL URLWithString:link]];
//    @weakify(self)
//    vc.clickMagnetCallBack = ^(NSString *url) {
//        @strongify(self)
//        if (!self) return;
//
//        [self downloadVideoWithMagnet:url];
//    };
//    [self.navigationController pushViewController:vc animated:YES];
//}

//- (void)touchLeftItem:(UIButton *)button {
//    [self.searchBar resignFirstResponder];
//    [super touchLeftItem:button];
//}

//- (void)configTitleView {
//    DDPExpandView *searchBarHolderView = [[DDPExpandView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
//    [searchBarHolderView addSubview:self.searchBar];
//    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_offset(0);
//        make.trailing.mas_offset(0);
//        make.top.bottom.mas_equalTo(0);
//    }];
//    self.navigationItem.titleView = searchBarHolderView;
//}


#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerClass:[HomePageSearchTableViewCell class] forCellReuseIdentifier:@"HomePageSearchTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        
        _tableView.titleForEmptyView = @"没有搜索到结果";
        _tableView.descriptionForEmptyView = @"换个关键词试试吧╮(╯▽╰)╭";
        _tableView.showEmptyView = YES;
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            if (self.config.keyword.length) {
                [DDPSearchNetManagerOperation searchDMHYWithConfig:self.config completionHandler:^(DDPDMHYSearchCollection *responseObject, NSError *error) {
                    if (error) {
                        [self.view showWithError:error];
                    }
                    else {
                        self.collection = responseObject;
                        if (responseObject.collection.count) {
                            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.top.mas_offset(FILTER_VIEW_HEIGHT);
                            }];
                            self.filterView.hidden = NO;
                            
                            NSMutableOrderedSet *typeSet = [NSMutableOrderedSet orderedSetWithObject:@"全部分类"];
                            NSMutableOrderedSet *subgroupNameSet = [NSMutableOrderedSet orderedSetWithObject:@"全部字幕组"];
                            
                            [responseObject.collection enumerateObjectsUsingBlock:^(DDPDMHYSearch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if (obj.typeName.length) {
                                    [typeSet addObject:obj.typeName];
                                }
                                
                                if (obj.subgroupName.length) {
                                    [subgroupNameSet addObject:obj.subgroupName];
                                }
                            }];
                            
                            HomePageSearchFilterModel *type = [[HomePageSearchFilterModel alloc] init];
                            type.title = typeSet.firstObject;
                            type.subItems = typeSet.array;
                            
                            HomePageSearchFilterModel *subGroups = [[HomePageSearchFilterModel alloc] init];
                            subGroups.title = subgroupNameSet.firstObject;
                            subGroups.subItems = subgroupNameSet.array;
                            
                            self.filterDataSource = @[type, subGroups];
                            
                            [self.filterView reloadData];
                        }
                        else {
                            self.filterView.hidden = YES;
                            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.top.mas_offset(0);
                            }];
                        }
//                        self.navigationItem.rightBarButtonItem.customView.userInteractionEnabled = !!self.config;
                        self.dataSource = responseObject.collection;
                        [self.tableView reloadData];
                    }
                    [self.tableView endRefreshing];
                }];
            }
            else {
                [self.tableView.mj_header endRefreshing];
            }
            
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

//- (DDPSearchBar *)searchBar {
//    if (_searchBar == nil) {
//        _searchBar = [[DDPSearchBar alloc] init];
//        _searchBar.placeholder = @"搜索资源";
//        _searchBar.delegate = self;
//        _searchBar.backgroundImage = [[UIImage alloc] init];
//        _searchBar.tintColor = [UIColor ddp_mainColor];
//        _searchBar.backgroundColor = [UIColor clearColor];
//        _searchBar.textField.font = [UIFont ddp_normalSizeFont];
//    }
//    return _searchBar;
//}

- (HomePageSearchFilterView *)filterView {
    if (_filterView == nil) {
        _filterView = [[HomePageSearchFilterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, FILTER_VIEW_HEIGHT)];
        _filterView.delegate = self;
        _filterView.dataSource = self;
        _filterView.hidden = YES;
        [self.view addSubview:_filterView];
    }
    return _filterView;
}
@end
