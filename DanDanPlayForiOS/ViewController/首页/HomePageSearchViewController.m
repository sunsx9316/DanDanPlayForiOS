//
//  HomePageSearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageSearchViewController.h"
#import "QRScanerViewController.h"
#import "JHBaseWebViewController.h"
#import "DownloadViewController.h"

#import "JHBaseTableView.h"
#import "HomePageSearchTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "HomePageSearchFilterView.h"
#import "JHEdgeButton.h"
#import "JHExpandView.h"
#import "JHSearchBar.h"
#import "HomePageSearchFilterModel.h"

@interface HomePageSearchViewController ()<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, HomePageSearchFilterViewDelegate, HomePageSearchFilterViewDataSource>
@property (strong, nonatomic) JHSearchBar *searchBar;
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) JHDMHYSearchCollection *collection;
@property (strong, nonatomic) HomePageSearchFilterView *filterView;
@property (strong, nonatomic) NSArray <JHDMHYSearch *>*dataSource;
@property (strong, nonatomic) NSArray <HomePageSearchFilterModel *>*filterDataSource;
@end

@implementation HomePageSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRightItem];
    [self configTitleView];
    
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.filterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(0);
        make.height.mas_equalTo(FILTER_VIEW_HEIGHT);
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
        [UIView performWithoutAnimation:^{
            [self.searchBar becomeFirstResponder];
        }];
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

#pragma mark - HomePageSearchFilterViewDataSource
- (NSInteger)numberOfItem {
    return self.filterDataSource.count;
}

- (NSString *)itemTitleAtSection:(NSInteger)index {
    return self.filterDataSource[index].title;
}

- (NSInteger)numberOfSubItemAtSection:(NSInteger)index {
    return self.filterDataSource[index].subItems.count;
}

- (NSString *)subItemTitleAtIndex:(NSInteger)index section:(NSInteger)section {
    return self.filterDataSource[section].subItems[index];
}

#pragma mark - HomePageSearchFilterViewDelegate
- (void)pageSearchFilterView:(HomePageSearchFilterView *)view didSelectedSubItemAtIndex:(NSInteger)index
                     section:(NSInteger)section
                       title:(NSString *)title {
    self.filterDataSource[section].title = title;
    
    NSString *type = [view titleInSection:0];
    NSString *subGroup = [view titleInSection:1];
    NSInteger typeIndex = [view selectedItemIndexAtSection:0];
    NSInteger subGroupIndex = [view selectedItemIndexAtSection:1];
    
    if (typeIndex == 0 && subGroupIndex == 0) {
        self.dataSource = self.collection.collection;
    }
    else {
        NSMutableArray *tempArr = [NSMutableArray array];
        [self.collection.collection enumerateObjectsUsingBlock:^(JHDMHYSearch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ((typeIndex == 0 || [obj.typeName isEqualToString:type]) && (subGroupIndex == 0 || [obj.subgroupName isEqualToString:subGroup])) {
                [tempArr addObject:obj];
            }
        }];
        self.dataSource = tempArr;
    }
    
    [self.tableView reloadData];
    [self.tableView reloadEmptyDataSet];
}

#pragma mark - 私有方法
- (void)downloadVideoWithMagnet:(NSString *)magnet {
    if (magnet.length == 0) return;
    
    @weakify(self)
    void(^downloadAction)(NSString *magnet) = ^(NSString *magnet){
        @strongify(self)
        if (!self) return;
        
        [MBProgressHUD showLoadingInView:self.view text:@"创建下载任务中..."];
        [LinkNetManager linkAddDownloadWithIpAdress:[CacheManager shareCacheManager].linkInfo.selectedIpAdress magnet:magnet completionHandler:^(JHLinkDownloadTask *responseObject, NSError *error) {
            @strongify(self)
            if (!self) return;
            
            [MBProgressHUD hideLoading];
            
            if (error) {
                [MBProgressHUD showWithError:error];
            }
            else {
                [[CacheManager shareCacheManager] addLinkDownload];
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"创建下载任务成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [vc addAction:[UIAlertAction actionWithTitle:@"下载列表" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    DownloadViewController *vc = [[DownloadViewController alloc] init];
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
            [MBProgressHUD showWithText:@"复制成功"];
        }]];
    
        [vc addAction:[UIAlertAction actionWithTitle:@"使用电脑端下载" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if ([CacheManager shareCacheManager].linkInfo == nil) {
                QRScanerViewController *vc = [[QRScanerViewController alloc] init];
                @weakify(self)
                vc.linkSuccessCallBack = ^(JHLinkInfo *info) {
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

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_browser"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
        aButton.userInteractionEnabled = !!self.config;
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)sender {
    
    NSString *link = self.config.link;
    if (link.length == 0) {
        link = [NSString stringWithFormat:@"https://share.dmhy.org/topics/list?keyword=%@", [self.config.keyword stringByURLEncode]];
    }
    
    [self.searchBar resignFirstResponder];
    
    JHBaseWebViewController *vc = [[JHBaseWebViewController alloc] initWithURL:[NSURL URLWithString:link]];
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
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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
                            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                                make.top.mas_offset(FILTER_VIEW_HEIGHT);
                            }];
                            self.filterView.hidden = NO;
                            
                            NSMutableOrderedSet *typeSet = [NSMutableOrderedSet orderedSetWithObject:@"全部分类"];
                            NSMutableOrderedSet *subgroupNameSet = [NSMutableOrderedSet orderedSetWithObject:@"全部字幕组"];
                            
                            [responseObject.collection enumerateObjectsUsingBlock:^(JHDMHYSearch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
                        self.navigationItem.rightBarButtonItem.customView.userInteractionEnabled = !!self.config;
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

- (JHSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[JHSearchBar alloc] init];
        _searchBar.placeholder = @"搜索资源";
        _searchBar.delegate = self;
        _searchBar.backgroundImage = [[UIImage alloc] init];
        _searchBar.tintColor = MAIN_COLOR;
        _searchBar.backgroundColor = [UIColor clearColor];
        _searchBar.textField.font = NORMAL_SIZE_FONT;
    }
    return _searchBar;
}

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
