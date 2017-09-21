//
//  HomePageSearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageSearchViewController.h"
#import "QRScanerViewController.h"
#import "WebViewController.h"
#import "DownloadViewController.h"

#import "BaseTableView.h"
#import "HomePageSearchTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "HomePageSearchFilterView.h"
#import "JHEdgeButton.h"
#import "JHExpandView.h"

@interface HomePageSearchViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) JHDMHYSearchCollection *collection;
@property (strong, nonatomic) HomePageSearchFilterView *filterView;
@property (strong, nonatomic) NSArray <JHDMHYSearch *>*dataSource;
@end

@implementation HomePageSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRightItem];
    [self configTitleView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (self.config) {
        self.searchBar.text = self.config.keyword;
        [self.tableView.mj_header beginRefreshing];
    }
    else {
        [self.tableView endRefreshing];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.config == nil) {
        [self.searchBar becomeFirstResponder];
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    JHDMHYSearchConfig *config = [[JHDMHYSearchConfig alloc] init];
    config.keyword = searchBar.text;
    self.config = config;
    [self.tableView.mj_header beginRefreshing];
    [searchBar endEditing:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomePageSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageSearchTableViewCell" forIndexPath:indexPath];
    cell.model = _dataSource[indexPath.row];
    @weakify(self)
    cell.touchSubGroupCallBack = ^(JHDMHYSearch *aModel) {
        @strongify(self)
        if (!self) return;
        
        HomePageSearchViewController *vc = [[HomePageSearchViewController alloc] init];
        JHDMHYSearchConfig *config = [[JHDMHYSearchConfig alloc] init];
        config.subGroupId = aModel.subgroupId;
        vc.config = config;
        [self.navigationController pushViewController:vc animated:YES];
    };
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self downloadVideoWithMagnet:self.dataSource[indexPath.row].magnet];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"HomePageSearchTableViewCell" cacheByIndexPath:indexPath configuration:^(HomePageSearchTableViewCell *cell) {
        cell.model = self.dataSource[indexPath.row];
    }];
}

#pragma mark - 私有方法
- (void)downloadVideoWithMagnet:(NSString *)magnet {
    if (magnet.length == 0) return;
    
    void(^downloadAction)(NSString *magnet) = ^(NSString *magnet){
        [LinkNetManager linkAddDownloadWithIpAdress:[CacheManager shareCacheManager].linkInfo.selectedIpAdress magnet:magnet completionHandler:^(JHLinkDownloadTask *responseObject, NSError *error) {
            if (error) {
                [MBProgressHUD showWithError:error];
            }
            else {
                [[CacheManager shareCacheManager] addLinkDownload];
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"创建下载任务成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [vc addAction:[UIAlertAction actionWithTitle:@"查看下载列表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    DownloadViewController *vc = [[DownloadViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }]];
                
                [vc addAction:[UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:nil]];
                
                [self presentViewController:vc animated:YES completion:nil];
                
            }
        }];
    };
    
    if ([CacheManager shareCacheManager].linkInfo == nil) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"选择操作" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"复制磁力链" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [UIPasteboard generalPasteboard].string = magnet;
            [MBProgressHUD showWithText:@"复制成功"];
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"使用电脑端下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            QRScanerViewController *vc = [[QRScanerViewController alloc] init];
            @weakify(self)
            vc.linkSuccessCallBack = ^(JHLinkInfo *info) {
                @strongify(self)
                if (!self) return;
                
                downloadAction(magnet);
            };
            [self.navigationController pushViewController:vc animated:YES];
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        downloadAction(magnet);
    }
}

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"browser"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)sender {
    if (self.config == nil) return;
    
    NSString *link = self.config.link;
    if (link.length == 0) {
        link = [NSString stringWithFormat:@"https://share.dmhy.org/topics/list?keyword=%@", [self.config.keyword stringByURLEncode]];
    }
    
    WebViewController *vc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:link]];
    @weakify(self)
    vc.clickMagnetCallBack = ^(NSString *url) {
        @strongify(self)
        if (!self) return;

        [self downloadVideoWithMagnet:url];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchLeftItem:(UIButton *)button {
    [self.searchBar resignFirstResponder];
    [super touchLeftItem:button];
}

- (void)configTitleView {
    JHExpandView *searchBarHolderView = [[JHExpandView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    [searchBarHolderView addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_offset(0);
        make.trailing.mas_offset(0);
        make.top.bottom.mas_equalTo(0);
    }];
    self.navigationItem.titleView = searchBarHolderView;
}


#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [_tableView registerClass:[HomePageSearchTableViewCell class] forCellReuseIdentifier:@"HomePageSearchTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            if (self.config) {
                [SearchNetManager searchDMHYWithConfig:self.config completionHandler:^(JHDMHYSearchCollection *responseObject, NSError *error) {
                    if (error) {
                        [MBProgressHUD showWithError:error atView:self.view];
                    }
                    else {
                        self.collection = responseObject;
                        if (responseObject.collection.count) {
                            [self.view addSubview:self.filterView];
                            [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
                                make.top.left.right.bottom.mas_equalTo(0);
                            }];
                            
                            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.top.mas_offset(FILTER_VIEW_HEIGHT);
                            }];
                            
                            NSMutableOrderedSet *typeSet = [NSMutableOrderedSet orderedSet];
                            NSMutableOrderedSet *subgroupNameSet = [NSMutableOrderedSet orderedSet];
                            
                            [responseObject.collection enumerateObjectsUsingBlock:^(JHDMHYSearch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                if (obj.typeName.length) {
                                    [typeSet addObject:obj.typeName];
                                }
                                
                                if (obj.subgroupName.length) {
                                    [subgroupNameSet addObject:obj.subgroupName];
                                }
                            }];
                            
                            self.filterView.types = typeSet.array;
                            self.filterView.subGroups = subgroupNameSet.array;
                            [self.filterView reload];
                        }
                        else {
                            [self.filterView removeFromSuperview];
                            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.top.mas_offset(0);
                            }];
                        }
                        
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

- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"搜索资源";
        _searchBar.delegate = self;
        _searchBar.backgroundImage = [[UIImage alloc] init];
        _searchBar.tintColor = MAIN_COLOR;
    }
    return _searchBar;
}

- (HomePageSearchFilterView *)filterView {
    if (_filterView == nil) {
        _filterView = [[HomePageSearchFilterView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, FILTER_VIEW_HEIGHT)];
        @weakify(self)
        void(^filterAction)(NSString *, NSString *) = ^(NSString *type, NSString *subGroup){
            @strongify(self)
            if (!self) return;
            
            if (type == nil && subGroup == nil) {
                self.dataSource = self.collection.collection;
            }
            else {
                NSMutableArray *tempArr = [NSMutableArray array];
                [self.collection.collection enumerateObjectsUsingBlock:^(JHDMHYSearch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ((type == nil || [obj.typeName isEqualToString:type]) && (subGroup == nil || [obj.subgroupName isEqualToString:subGroup])) {
                        [tempArr addObject:obj];
                    }
                }];
                self.dataSource = tempArr;
            }
            
            [self.tableView reloadData];
        };
        
        
        _filterView.selectedTypeCallBack = ^(NSString *typeName) {
            @strongify(self)
            if (!self) return;
            
            filterAction(typeName, self.filterView.subGroupName);
        };
        
        _filterView.selectedSubGroupsCallBack = ^(NSString *subGroupName) {
            @strongify(self)
            if (!self) return;
            
            filterAction(self.filterView.typeName, subGroupName);
        };
    }
    return _filterView;
}

@end
