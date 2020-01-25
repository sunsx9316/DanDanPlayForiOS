//
//  DDPMatchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMatchViewController.h"
#import "DDPSearchViewController.h"

#import "DDPMatchTableViewCell.h"
#import "DDPMatchTitleTableViewCell.h"

#import <UITableView+FDTemplateLayoutCell.h>
#import "DDPBaseTreeView.h"
#import "DDPEdgeButton.h"
#import "DDPSearchBar.h"
#import "DDPExpandView.h"

#if !DDPAPPTYPEISMAC
#import "DDPPlayNavigationController.h"
#import "DDPPlayerViewController.h"
#else
#import <DDPShare/DDPShare.h>
#endif

@interface DDPMatchViewController ()<RATreeViewDelegate, RATreeViewDataSource, UISearchBarDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (strong, nonatomic) DDPBaseTreeView *treeView;
@property (strong, nonatomic) DDPSearchBar *searchBar;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <DDPMatch *>*>*classifyDic;
@end

@implementation DDPMatchViewController
{
    NSArray <NSString *>*_resortKeys;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"快速匹配";
    [self configRightItem];
    [self configTitleView];
    
    [self.treeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.treeView.ddp_tableView.mj_header beginRefreshing];
}

#pragma mark - RATreeViewDelegate
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
    if ([item isKindOfClass:[NSString class]]) {
        return 44;
    }
    
    return [treeView.ddp_tableView fd_heightForCellWithIdentifier:@"DDPMatchTableViewCell" cacheByKey:item configuration:^(DDPMatchTableViewCell *cell) {
        cell.model = item;
    }];
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
    if ([item isKindOfClass:[NSString class]]) {
        DDPMatchTitleTableViewCell *cell = (DDPMatchTitleTableViewCell *)[treeView cellForItem:item];
        [cell expandArrow:YES animate:YES];
    }
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
    if ([item isKindOfClass:[NSString class]]) {
        DDPMatchTitleTableViewCell *cell = (DDPMatchTitleTableViewCell *)[treeView cellForItem:item];
        [cell expandArrow:NO animate:YES];
    }
}

- (UITableViewCellEditingStyle)treeView:(RATreeView *)treeView editingStyleForRowForItem:(DDPFile *)item {
    return UITableViewCellEditingStyleNone;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(DDPMatch *)item {
    [treeView deselectRowForItem:item animated:YES];
    if ([item isKindOfClass:[DDPMatch class]]) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];

        [DDPCommentNetManagerOperation danmakusWithEpisodeId:item.identity progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = ddp_danmakusProgressToString(progress);
        } completionHandler:^(DDPDanmakuCollection *responseObject, NSError *error) {
            [aHUD hideAnimated:NO];
            self.model.danmakus = responseObject;
            self.model.matchName = item.name;
            self.model.identity = item.identity;
            [self jumpToPlayVC];
        }];
    }
}

#pragma mark - RATreeViewDataSource
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(nullable id)item {
    if (item == nil) {
        return _resortKeys.count;
    }
    
    if ([item isKindOfClass:[NSString class]]) {
        NSArray *arr = self.classifyDic[item];
        return arr.count;
    }
    
    return 0;
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(nullable id)item {
    if ([item isKindOfClass:[NSString class]]) {
        DDPMatchTitleTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"DDPMatchTitleTableViewCell"];
        cell.titleLabel.text = item;
        [cell expandArrow:[treeView isCellForItemExpanded:item] animate:NO];
        return cell;
    }
    
    DDPMatchTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"DDPMatchTableViewCell"];
    cell.model = item;
    return cell;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return _resortKeys[index];
    }
    
    return self.classifyDic[item][index];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (searchBar.text.length) {
        [searchBar resignFirstResponder];
        
        DDPSearchViewController *vc = [[DDPSearchViewController alloc] init];
        vc.model = self.model;
        vc.keyword = searchBar.text;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击直接播放" attributes:@{NSFontAttributeName : [UIFont ddp_smallSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.treeView.ddp_tableView.showEmptyView;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
    [self jumpToPlayVC];
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - 私有方法
- (void)classifyWithColletion:(DDPMatchCollection *)collection {
    [self.classifyDic removeAllObjects];
    
    [collection.collection enumerateObjectsUsingBlock:^(DDPMatch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.classifyDic[obj.typeDescription] == nil) {
            self.classifyDic[obj.typeDescription] = [NSMutableArray array];
        }
        
        [self.classifyDic[obj.typeDescription] addObject:obj];
    }];
    
    _resortKeys = [[self.classifyDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}

- (void)jumpToPlayVC {
#if !DDPAPPTYPEISMAC
    __block DDPPlayerViewController *vc = nil;
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[DDPPlayerViewController class]]) {
            vc = obj;
            *stop = YES;
        }
    }];
    
    //更改匹配信息
    [DDPMatchNetManagerOperation matchEditMatchVideoModel:self.model user:[DDPCacheManager shareCacheManager].currentUser completionHandler:^(NSError *error) {
        LOG_ERROR(DDPLogModuleFile, @"匹配失败 %@", error);
    }];
    
    if (vc) {
        vc.model = self.model;
        [self.navigationController popToViewController:vc animated:YES];
    }
    else {
        DDPPlayNavigationController *nav = [[DDPPlayNavigationController alloc] initWithModel:self.model];
        [self presentViewController:nav animated:YES completion:nil];
    }
#else
    //更改匹配信息
    [DDPMatchNetManagerOperation matchEditMatchVideoModel:self.model user:[DDPCacheManager shareCacheManager].currentUser completionHandler:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
    if (self.model.danmakus == nil) {
        self.model.danmakus = [[DDPDanmakuCollection alloc] init];
        self.model.danmakus.collection = [NSMutableArray array];
    }
    [DDPMethod sendMatchedModelMessage:self.model];
#endif
}

- (void)configRightItem {

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"直接播放" configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)button {
    [self jumpToPlayVC];
}

- (void)configTitleView {
    DDPExpandView *view = [[DDPExpandView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SEARCH_BAR_HEIRHT)];
    [view addSubview:self.searchBar];
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.navigationItem.titleView = view;
}

#pragma mark - 懒加载
- (DDPBaseTreeView *)treeView {
    if (_treeView == nil) {
        _treeView = [[DDPBaseTreeView alloc] initWithFrame:CGRectZero style:RATreeViewStylePlain];
        _treeView.delegate = self;
        _treeView.dataSource = self;
        _treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
        _treeView.rowsExpandingAnimation = RATreeViewRowAnimationTop;
        _treeView.rowsCollapsingAnimation = RATreeViewRowAnimationTop;
        _treeView.ddp_tableView.emptyDataSetSource = self;
        _treeView.ddp_tableView.emptyDataSetDelegate = self;
        [_treeView registerClass:[DDPMatchTableViewCell class] forCellReuseIdentifier:@"DDPMatchTableViewCell"];
        [_treeView registerClass:[DDPMatchTitleTableViewCell class] forCellReuseIdentifier:@"DDPMatchTitleTableViewCell"];
        @weakify(self)
        _treeView.ddp_tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [DDPMatchNetManagerOperation matchVideoModel:self.model completionHandler:^(DDPMatchCollection *responseObject, NSError *error) {
                if (error) {
                    [self.view showWithError:error];
                }
                else {
                    [self classifyWithColletion:responseObject];
                    [self.treeView reloadData];
                    [self.treeView expandRowForItem:self->_resortKeys.firstObject expandChildren:true withRowAnimation:RATreeViewRowAnimationNone];
                }
                
                [self.treeView endRefreshing];
            }];
        }];
        [self.view addSubview:_treeView];
    }
    return _treeView;
}

- (DDPSearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[DDPSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = @"试试手动♂搜索";
        _searchBar.returnKeyType = UIReturnKeySearch;
        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}

- (NSMutableDictionary<NSString *,NSMutableArray<DDPMatch *> *> *)classifyDic {
    if (_classifyDic == nil) {
        _classifyDic = [NSMutableDictionary dictionary];
    }
    return _classifyDic;
}

@end
