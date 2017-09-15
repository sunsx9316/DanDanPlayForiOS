//
//  HomePageSearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageSearchViewController.h"
#import "QRScanerViewController.h"

#import "BaseTableView.h"
#import "HomePageSearchTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "HomePageSearchFilterView.h"
#import "JHEdgeButton.h"

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
    self.navigationItem.titleView = self.searchBar;
//    [self configRightItem];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (self.config) {
        self.searchBar.text = self.config.keyword;
        [self.tableView.mj_header beginRefreshing];
    }
    else {
        [self.searchBar becomeFirstResponder];
    }
}

- (void)configLeftItem {
    [super configLeftItem];
    UIBarButtonItem *item = self.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItem = nil;
    UIBarButtonItem *spaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceBar.width = 15;
    self.navigationItem.leftBarButtonItems = @[item, spaceBar];
}

- (void)configRightItem {
    JHEdgeButton *backButton = [[JHEdgeButton alloc] init];
    backButton.inset = CGSizeMake(10, 10);
    [backButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setTitle:@"下载" forState:UIControlStateNormal];
    [backButton sizeToFit];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    UIBarButtonItem *rightSpaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSpaceBar.width = -5;
    
    UIBarButtonItem *leftSpaceBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSpaceBar.width = 10;
    
    self.navigationItem.rightBarButtonItems = @[rightSpaceBar, item, leftSpaceBar];
}

- (void)touchRightItem:(UIButton *)sender {
    
}

- (void)touchLeftItem:(UIButton *)button {
    [self.searchBar resignFirstResponder];
    [super touchLeftItem:button];
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
    
    void(^downloadAction)(JHDMHYSearch *) = ^(JHDMHYSearch *model){
        [LinkNetManager linkAddDownloadWithIpAdress:[CacheManager shareCacheManager].linkInfo.selectedIpAdress magnet:model.magnet completionHandler:^(JHLinkDownloadTask *responseObject, NSError *error) {
            if (error) {
                [MBProgressHUD showWithError:error];
            }
            else {
                [[CacheManager shareCacheManager] addLinkDownload];
                [MBProgressHUD showWithText:@"添加成功！"];
            }
        }];
    };
    
    if ([CacheManager shareCacheManager].linkInfo == nil) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"需要连接到电脑版才能下载~" message:@"请打开电脑版的\"远程访问\"" preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            QRScanerViewController *vc = [[QRScanerViewController alloc] init];
            @weakify(self)
            vc.linkSuccessCallBack = ^(JHLinkInfo *info) {
                @strongify(self)
                if (!self) return;
                
                downloadAction(_dataSource[indexPath.row]);
            };
            [self.navigationController pushViewController:vc animated:YES];
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        downloadAction(_dataSource[indexPath.row]);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [tableView fd_heightForCellWithIdentifier:@"HomePageSearchTableViewCell" cacheByIndexPath:indexPath configuration:^(HomePageSearchTableViewCell *cell) {
        cell.model = self.dataSource[indexPath.row];
    }];
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
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 30)];
        _searchBar.placeholder = @"搜索文件名";
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
