//
//  HomePageViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageViewController.h"
#import "HomePageItemViewController.h"
#import "JHBaseWebViewController.h"
#import "HomePageSearchViewController.h"
#import "AttentionListViewController.h"
#import "AttentionDetailViewController.h"
#import "HomePageItemViewController.h"
#import "JHBaseWebViewController.h"

#import "HomePageHeaderTableViewCell.h"
#import "MJRefreshHeader+Tools.h"
#import "NSDate+Tools.h"
#import "JHEdgeButton.h"
#import <UMSocialCore/UMSocialCore.h>
#import "JHBaseTableView.h"
#import "TextHeaderView.h"
#import <WMMenuView.h>
#import "HomePageItemTableViewCell.h"
#import "HomePageBangumiProgressTableViewCell.h"


@interface HomePageViewController ()<UITableViewDelegate, UITableViewDataSource, WMMenuViewDataSource, WMMenuViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) JHBaseTableView *tableView;
//@property (strong, nonatomic) HomePageHeaderTableViewCell *headerView;
@property (strong, nonatomic) JHHomePage *model;
@property (strong, nonatomic) JHBangumiQueueIntroCollection *collection;
//@property (strong, nonatomic) WMMenuView *menuView;
@end

@implementation HomePageViewController
//{
//    BOOL _isTouchMenuItem;
//    NSInteger _selectedIndex;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"首页";
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAttention:) name:ATTENTION_SUCCESS_NOTICE object:nil];
    
    [self.tableView.mj_header beginRefreshing];
    [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"user" options:NSKeyValueObservingOptionNew context:nil];
    
    //当前版本小于9.0
    if ([[UIDevice currentDevice].systemVersion compare:MINI_SUPPORT_VERTSION options:NSNumericSearch] == NSOrderedAscending) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"当前系统版本过旧 请升级到iOS %@以上版本", MINI_SUPPORT_VERTSION] preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            exit(0);
        }]];
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"user"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"user"]) {
        if (self.tableView.mj_header.refreshingBlock) {
            self.tableView.mj_header.refreshingBlock();
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    JHHomeBangumiCollection *collection = [self bangumiCollectionWithIndex:section];
//    return collection.collection.count;
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return self.model.bangumis.count;
    return !![CacheManager shareCacheManager].user * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HomePageHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageHeaderTableViewCell" forIndexPath:indexPath];
        @weakify(self)
        cell.touchSearchButtonCallBack = ^{
            @strongify(self)
            if (!self) return;
            
            HomePageSearchViewController *vc = [[HomePageSearchViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        cell.touchTimeLineButtonCallBack = ^{
            HomePageItemViewController *item
//            if ([CacheManager shareCacheManager].user == nil) {
//                [[ToolsManager shareToolsManager] popLoginAlertViewInViewController:self];
//            }
//            else {
//                AttentionListViewController *vc = [[AttentionListViewController alloc] init];
//                vc.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:vc animated:YES];
//            }
        };
        
        cell.dataSource = self.model.banners;
        return cell;
    }
    
    HomePageBangumiProgressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageBangumiProgressTableViewCell" forIndexPath:indexPath];
    cell.collection = self.collection;
    return cell;
    
//    HomePageItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageItemTableViewCell" forIndexPath:indexPath];
//    JHHomeBangumiCollection *collection = [self bangumiCollectionWithIndex:indexPath.section];
//    JHHomeBangumi *model = collection.collection[indexPath.row];
//    cell.model = model;
//    @weakify(self)
//    cell.touchLikeCallBack = ^(JHHomeBangumi *aModel) {
//        @strongify(self)
//        if (!self) return;
//
//        JHUser *user = [CacheManager shareCacheManager].user;
//        [MBProgressHUD showLoadingInView:self.view text:@"请求中..."];
//        [FavoriteNetManager favoriteLikeWithUser:user animeId:aModel.identity like:!aModel.isFavorite completionHandler:^(NSError *error) {
//            [MBProgressHUD hideLoading];
//            @strongify(self)
//            if (!self) return;
//
//            if (error) {
//                [MBProgressHUD showWithError:error atView:self.view];
//            }
//            else {
//                aModel.isFavorite = !aModel.isFavorite;
//                [self resortBangumisAtSection:indexPath.section];
//                [self.tableView reloadData];
//            }
//        }];
//    };
//
//    cell.selectedItemCallBack = ^(JHHomeBangumiSubtitleGroup *aModel) {
//        @strongify(self)
//        if (!self) return;
//
//        JHDMHYParse *parseModel = [aModel parseModel];
//
//        HomePageSearchViewController *vc = [[HomePageSearchViewController alloc] init];
//        JHDMHYSearchConfig *config = [[JHDMHYSearchConfig alloc] init];
//        config.keyword = model.name;
//        config.subGroupId = parseModel.identity;
//        config.link = parseModel.link;
//        vc.config = config;
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    };
//
//    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
//    JHHomeBangumiCollection *collecion = [self bangumiCollectionWithIndex:section];
    TextHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TextHeaderView"];
//    [view.layer setLayerShadow:[UIColor lightGrayColor] offset:CGSizeMake(0, 2) radius:2];
    view.titleLabel.text = @"追番进度";
    return view;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return HOME_PAGE_HEADER_HEIGHT;
    }
    return 250 + (jh_isPad() * 40);
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    JHHomeBangumiCollection *collecion = [self bangumiCollectionWithIndex:indexPath.section];
//    JHHomeBangumi *model = collecion.collection[indexPath.row];
//
//    AttentionDetailViewController *vc = [[AttentionDetailViewController alloc] init];
//    vc.animateId = model.identity;
//    vc.isOnAir = YES;
//    @weakify(self)
//    vc.attentionCallBack = ^(NSUInteger animateId) {
//        @strongify(self)
//        if (!self) return;
//
//        model.isFavorite = YES;
//        [self resortBangumisAtSection:indexPath.section];
//        [self.tableView reloadData];
//    };
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 30;
}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return CGFLOAT_MIN;
//}
//
//#pragma mark - WMMenuViewDataSource
//- (NSInteger)numbersOfTitlesInMenuView:(WMMenuView *)menu {
//    return self.model.bangumis.count;
//}
//
//- (NSString *)menuView:(WMMenuView *)menu titleAtIndex:(NSInteger)index {
//    JHHomeBangumiCollection *collection = [self bangumiCollectionWithIndex:index];
//    return collection.weekDayStringValue;
//}
//
//#pragma mark - WMMenuViewDelegate
//- (UIColor *)menuView:(WMMenuView *)menu titleColorForState:(WMMenuItemState)state atIndex:(NSInteger)index {
//    if (state == WMMenuItemStateNormal) {
//        return [UIColor lightGrayColor];
//    }
//    return MAIN_COLOR;
//}
//
//- (CGFloat)menuView:(WMMenuView *)menu itemMarginAtIndex:(NSInteger)index {
//    return 10;
//}
//
//- (CGFloat)menuView:(WMMenuView *)menu titleSizeForState:(WMMenuItemState)state atIndex:(NSInteger)index {
//    if (state == WMMenuItemStateSelected) {
//        return NORMAL_SIZE_FONT.pointSize;
//    }
//    return SMALL_SIZE_FONT.pointSize;
//}
//
//- (void)menuView:(WMMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
//    _isTouchMenuItem = YES;
//    [self.tableView scrollToRow:0 inSection:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
//}
//
//- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
//    JHHomeBangumiCollection *collection = [self bangumiCollectionWithIndex:index];
//    NSString *string = collection.weekDayStringValue;
//    return [string sizeForFont:NORMAL_SIZE_FONT size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping].width + 20;
//}
//
//#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    _isTouchMenuItem = NO;
//}
//
//- (void)scrollViewDidScroll:(UITableView *)scrollView {
//    CGPoint offset = scrollView.contentOffset;
//    CGFloat y = scrollView.contentOffset.y + MENU_VIEW_HEIGHT;
//    offset.y = y;
//
//    y /= HOME_PAGE_HEADER_HEIGHT;
//    y = MIN(MAX(y, 0), 1);
//    _menuView.alpha = y;
//
//    NSIndexPath *indexPath = [scrollView indexPathForRowAtPoint:offset];
//    if (indexPath.section != _selectedIndex && _isTouchMenuItem == NO) {
//        [_menuView slideMenuAtProgress:indexPath.section];
//        _selectedIndex = indexPath.section;
//    }
//}
//
//#pragma mark - 私有方法
//- (void)cancelAttention:(NSNotification *)aSender {
//    NSInteger animateId = [aSender.object integerValue];
//    BOOL attention = [aSender.userInfo[ATTENTION_SUCCESS_NOTICE] boolValue];
//    [self.model.bangumis enumerateObjectsUsingBlock:^(JHHomeBangumiCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [obj.collection enumerateObjectsUsingBlock:^(JHHomeBangumi * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
//            if (obj1.identity == animateId) {
//                obj1.isFavorite = attention;
//                [self resortBangumisAtSection:idx];
//                [self.tableView reloadData];
//                *stop1 = YES;
//                *stop = YES;
//            }
//        }];
//    }];
//}
//
//- (void)resortBangumisAtSection:(NSUInteger)section {
//    //全部重排
//    if (section == NSNotFound) {
//        //收藏排在前面
//        [self.model.bangumis enumerateObjectsUsingBlock:^(JHHomeBangumiCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            [obj.collection sortUsingComparator:^NSComparisonResult(JHHomeBangumi * _Nonnull obj1, JHHomeBangumi * _Nonnull obj2) {
//                return obj2.isFavorite - obj1.isFavorite;
//            }];
//        }];
//    }
//    //只重排分区
//    else {
//        JHHomeBangumiCollection *collection = self.model.bangumis[section];
//        [collection.collection sortUsingComparator:^NSComparisonResult(JHHomeBangumi * _Nonnull obj1, JHHomeBangumi * _Nonnull obj2) {
//            return obj2.isFavorite - obj1.isFavorite;
//        }];
//    }
//}
//
//- (JHHomeBangumiCollection *)bangumiCollectionWithIndex:(NSInteger)index {
//    NSInteger week = [NSDate currentWeekDay];
//    if (week < 0 || week > 7) {
//        return self.model.bangumis[index];
//    }
//    index = (index + week) % self.model.bangumis.count;
//    return self.model.bangumis[index];
//}

- (void)configLeftItem {
    
}

#pragma mark - 懒加载
- (void)touchTimeLineButton:(UIButton *)button {
    if ([CacheManager shareCacheManager].user == nil) {
        [[ToolsManager shareToolsManager] popLoginAlertViewInViewController:self];
    }
    else {
        AttentionListViewController *vc = [[AttentionListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)touchSearchButton:(UIButton *)button {
    HomePageSearchViewController *vc = [[HomePageSearchViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
//        _tableView.tableHeaderView = self.headerView;
//        _tableView.rowHeight = ITEM_CELL_HEIGHT + 20;
//        _tableView.contentInset = UIEdgeInsetsMake(MENU_VIEW_HEIGHT, 0, 0, 0);
//        [_tableView registerClass:[HomePageItemTableViewCell class] forCellReuseIdentifier:@"HomePageItemTableViewCell"];
        [_tableView registerClass:[TextHeaderView class] forHeaderFooterViewReuseIdentifier:@"TextHeaderView"];
        [_tableView registerClass:[HomePageHeaderTableViewCell class] forCellReuseIdentifier:@"HomePageHeaderTableViewCell"];
        [_tableView registerClass:[HomePageBangumiProgressTableViewCell class] forCellReuseIdentifier:@"HomePageBangumiProgressTableViewCell"];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [RecommedNetManager recommedInfoWithCompletionHandler:^(JHHomePage *responseObject, NSError *error) {
                
                if (error) {
                    [MBProgressHUD showWithError:error atView:self.view];
                }
                else {
                    self.model = responseObject;
//                    self.headerView.dataSource = self.model.banners;
//                    [self resortBangumisAtSection:NSNotFound];
//                    self.headerView.hidden = NO;
                    [self.tableView reloadData];
//                    [self.menuView reload];
                }
                
                [self.tableView endRefreshing];
            }];
            
            if ([CacheManager shareCacheManager].user) {
                [PlayHistoryNetManager playHistoryWithUser:[CacheManager shareCacheManager].user completionHandler:^(JHBangumiQueueIntroCollection *responseObject, NSError *error) {
                    if (error) {
                        [MBProgressHUD showWithError:error];
                    }
                    else {
                        self.collection = responseObject;
                        [self.tableView reloadData];
                    }
                }];
            }
        }];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

//- (HomePageHeaderTableViewCell *)headerView {
//    if (_headerView == nil) {
//        _headerView = [[HomePageHeaderTableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.width, HOME_PAGE_HEADER_HEIGHT)];
//        _headerView.hidden = YES;
//        @weakify(self)
//        _headerView.didSelctedModelCallBack = ^(JHHomeBanner *model) {
//            @strongify(self)
//            if (!self) return;
//
//            JHBaseWebViewController *vc = [[JHBaseWebViewController alloc] initWithURL:model.link];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        };
//        [_headerView.timeLineButton addTarget:self action:@selector(touchTimeLineButton:) forControlEvents:UIControlEventTouchUpInside];
//        [_headerView.searchButton addTarget:self action:@selector(touchSearchButton:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _headerView;
//}

//- (WMMenuView *)menuView {
//    if (_menuView == nil) {
//        _menuView = [[WMMenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, MENU_VIEW_HEIGHT)];
//        _menuView.delegate = self;
//        _menuView.dataSource = self;
//        _menuView.backgroundColor = [UIColor whiteColor];
//        _menuView.style = WMMenuViewStyleLine;
//        _menuView.alpha = 0;
//        [self.view addSubview:_menuView];
//        [_menuView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.left.right.mas_equalTo(0);
//            make.height.mas_equalTo(MENU_VIEW_HEIGHT);
//        }];
//    }
//    return _menuView;
//}

@end


