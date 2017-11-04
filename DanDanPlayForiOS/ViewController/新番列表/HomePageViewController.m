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
#import "JHBaseWebViewController.h"

#import "HomePageHeaderView.h"
#import "MJRefreshHeader+Tools.h"
#import "NSDate+Tools.h"
#import "JHEdgeButton.h"
#import <UMSocialCore/UMSocialCore.h>
#import "JHBaseTableView.h"
#import "TextHeaderView.h"
#import <WMMenuView.h>
#import "HomePageItemTableViewCell.h"



@interface HomePageViewController ()<UITableViewDelegate, UITableViewDataSource, WMMenuViewDataSource, WMMenuViewDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) HomePageHeaderView *headerView;
@property (strong, nonatomic) JHHomePage *model;
@property (strong, nonatomic) WMMenuView *menuView;
//<WMPageControllerDelegate, WMPageControllerDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
//@property (strong, nonatomic) JHDefaultPageViewController *pageViewController;
//@property (strong, nonatomic) JHHomePage *model;
@end

@implementation HomePageViewController
{
    BOOL _isTouchMenuItem;
    NSInteger _selectedIndex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"新番列表";
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAttention:) name:ATTENTION_SUCCESS_NOTICE object:nil];
    
    [self.tableView.mj_header beginRefreshing];
    [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"user" options:NSKeyValueObservingOptionNew context:nil];
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
    JHBangumiCollection *collection = [self bangumiCollectionWithIndex:section];
    return collection.collection.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.model.bangumis.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomePageItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageItemTableViewCell" forIndexPath:indexPath];
    JHBangumiCollection *collection = [self bangumiCollectionWithIndex:indexPath.section];
    JHBangumi *model = collection.collection[indexPath.row];
    cell.model = model;
    @weakify(self)
    cell.touchLikeCallBack = ^(JHBangumi *aModel) {
        @strongify(self)
        if (!self) return;
        
        JHUser *user = [CacheManager shareCacheManager].user;
        [MBProgressHUD showLoadingInView:self.view text:@"请求中..."];
        [FavoriteNetManager favoriteLikeWithUser:user animeId:aModel.identity like:!aModel.isFavorite completionHandler:^(NSError *error) {
            [MBProgressHUD hideLoading];
            @strongify(self)
            if (!self) return;
            
            if (error) {
                [MBProgressHUD showWithError:error atView:self.view];
            }
            else {
                aModel.isFavorite = !aModel.isFavorite;
                [self resortBangumisAtSection:indexPath.section];
                [self.tableView reloadData];
            }
        }];
    };
    
    cell.selectedItemCallBack = ^(JHBangumiGroup *aModel) {
        @strongify(self)
        if (!self) return;
        
        JHDMHYParse *parseModel = [aModel parseModel];
        
        HomePageSearchViewController *vc = [[HomePageSearchViewController alloc] init];
        JHDMHYSearchConfig *config = [[JHDMHYSearchConfig alloc] init];
        config.keyword = model.name;
        config.subGroupId = parseModel.identity;
        config.link = parseModel.link;
        vc.config = config;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    JHBangumiCollection *collecion = [self bangumiCollectionWithIndex:section];
    TextHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TextHeaderView"];
    view.titleLabel.text = collecion.weekDayStringValue;
    return view;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JHBangumiCollection *collecion = [self bangumiCollectionWithIndex:indexPath.section];
    JHBangumi *model = collecion.collection[indexPath.row];
    
    AttentionDetailViewController *vc = [[AttentionDetailViewController alloc] init];
    vc.animateId = model.identity;
    vc.isOnAir = YES;
    @weakify(self)
    vc.attentionCallBack = ^(NSUInteger animateId) {
        @strongify(self)
        if (!self) return;
        
        model.isFavorite = YES;
        [self resortBangumisAtSection:indexPath.section];
        [self.tableView reloadData];
    };
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

#pragma mark - WMMenuViewDataSource
- (NSInteger)numbersOfTitlesInMenuView:(WMMenuView *)menu {
    return self.model.bangumis.count;
}

- (NSString *)menuView:(WMMenuView *)menu titleAtIndex:(NSInteger)index {
    JHBangumiCollection *collection = [self bangumiCollectionWithIndex:index];
    return collection.weekDayStringValue;
}

#pragma mark - WMMenuViewDelegate
- (UIColor *)menuView:(WMMenuView *)menu titleColorForState:(WMMenuItemState)state atIndex:(NSInteger)index {
    if (state == WMMenuItemStateNormal) {
        return [UIColor lightGrayColor];
    }
    return MAIN_COLOR;
}

- (CGFloat)menuView:(WMMenuView *)menu itemMarginAtIndex:(NSInteger)index {
    return 10;
}

- (CGFloat)menuView:(WMMenuView *)menu titleSizeForState:(WMMenuItemState)state atIndex:(NSInteger)index {
    if (state == WMMenuItemStateSelected) {
        return NORMAL_SIZE_FONT.pointSize;
    }
    return SMALL_SIZE_FONT.pointSize;
}

- (void)menuView:(WMMenuView *)menu didSelesctedIndex:(NSInteger)index currentIndex:(NSInteger)currentIndex {
    _isTouchMenuItem = YES;
    [self.tableView scrollToRow:0 inSection:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (CGFloat)menuView:(WMMenuView *)menu widthForItemAtIndex:(NSInteger)index {
    JHBangumiCollection *collection = [self bangumiCollectionWithIndex:index];
    NSString *string = collection.weekDayStringValue;
    return [string sizeForFont:NORMAL_SIZE_FONT size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping].width + 20;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _isTouchMenuItem = NO;
}

- (void)scrollViewDidScroll:(UITableView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    CGFloat y = scrollView.contentOffset.y + MENU_VIEW_HEIGHT;
    offset.y = y;
    
    y /= HOME_PAGE_HEADER_HEIGHT;
    y = MIN(MAX(y, 0), 1);
    _menuView.alpha = y;
    
    NSIndexPath *indexPath = [scrollView indexPathForRowAtPoint:offset];
    if (indexPath.section != _selectedIndex && _isTouchMenuItem == NO) {
        [_menuView slideMenuAtProgress:indexPath.section];
        _selectedIndex = indexPath.section;
    }
}

#pragma mark - 私有方法
- (void)cancelAttention:(NSNotification *)aSender {
    NSInteger animateId = [aSender.object integerValue];
    BOOL attention = [aSender.userInfo[ATTENTION_SUCCESS_NOTICE] boolValue];
    [self.model.bangumis enumerateObjectsUsingBlock:^(JHBangumiCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.collection enumerateObjectsUsingBlock:^(JHBangumi * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
            if (obj1.identity == animateId) {
                obj1.isFavorite = attention;
                [self resortBangumisAtSection:idx];
                [self.tableView reloadData];
                *stop1 = YES;
                *stop = YES;
            }
        }];
    }];
}

- (void)resortBangumisAtSection:(NSUInteger)section {
    //全部重排
    if (section == NSNotFound) {
        //收藏排在前面
        [self.model.bangumis enumerateObjectsUsingBlock:^(JHBangumiCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.collection sortUsingComparator:^NSComparisonResult(JHBangumi * _Nonnull obj1, JHBangumi * _Nonnull obj2) {
                return obj2.isFavorite - obj1.isFavorite;
            }];
        }];
    }
    //只重排分区
    else {
        JHBangumiCollection *collection = self.model.bangumis[section];
        [collection.collection sortUsingComparator:^NSComparisonResult(JHBangumi * _Nonnull obj1, JHBangumi * _Nonnull obj2) {
            return obj2.isFavorite - obj1.isFavorite;
        }];
    }
}

- (JHBangumiCollection *)bangumiCollectionWithIndex:(NSInteger)index {
    NSInteger week = [NSDate currentWeekDay];
    if (week < 0 || week > 7) {
        return self.model.bangumis[index];
    }
    index = (index + week) % self.model.bangumis.count;
    return self.model.bangumis[index];
}

- (void)configLeftItem {
    
}

#pragma mark - 懒加载
- (void)touchAttionButton:(UIButton *)button {
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
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.headerView;
        _tableView.rowHeight = ITEM_CELL_HEIGHT + 20;
        _tableView.contentInset = UIEdgeInsetsMake(MENU_VIEW_HEIGHT, 0, 0, 0);
        [_tableView registerClass:[HomePageItemTableViewCell class] forCellReuseIdentifier:@"HomePageItemTableViewCell"];
        [_tableView registerClass:[TextHeaderView class] forHeaderFooterViewReuseIdentifier:@"TextHeaderView"];
        
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
                    self.headerView.dataSource = self.model.bannerPages;
                    [self resortBangumisAtSection:NSNotFound];
                    self.headerView.hidden = NO;
                    [self.tableView reloadData];
                    [self.menuView reload];
                }
                
                [self.tableView endRefreshing];
            }];
        }];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (HomePageHeaderView *)headerView {
    if (_headerView == nil) {
        _headerView = [[HomePageHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, HOME_PAGE_HEADER_HEIGHT)];
        _headerView.hidden = YES;
        @weakify(self)
        _headerView.didSelctedModelCallBack = ^(JHBannerPage *model) {
            @strongify(self)
            if (!self) return;
            
            JHBaseWebViewController *vc = [[JHBaseWebViewController alloc] initWithURL:model.link];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        };
        [_headerView.attionButton addTarget:self action:@selector(touchAttionButton:) forControlEvents:UIControlEventTouchUpInside];
        [_headerView.searchButton addTarget:self action:@selector(touchSearchButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headerView;
}

- (WMMenuView *)menuView {
    if (_menuView == nil) {
        _menuView = [[WMMenuView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, MENU_VIEW_HEIGHT)];
        _menuView.delegate = self;
        _menuView.dataSource = self;
        _menuView.backgroundColor = [UIColor whiteColor];
        _menuView.style = WMMenuViewStyleLine;
        _menuView.alpha = 0;
        [self.view addSubview:_menuView];
        [_menuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(MENU_VIEW_HEIGHT);
        }];
    }
    return _menuView;
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"user"]) {
//        [self requestHomePageWithAnimate:NO completion:^{
//            [self.pageViewController reloadData];
//        }];
//    }
//}
//
//- (void)dealloc {
//    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"user"];
//}
//
//#pragma mark - WMPageControllerDataSource
//- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
//    return self.model.bangumis.count;
//}
//
//- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
//    HomePageItemViewController *vc = [[HomePageItemViewController alloc] init];
//    vc.bangumis = [self bangumiCollectionWithIndex:index].collection;
//    @weakify(vc)
//    @weakify(self)
//    vc.handleBannerCallBack = ^() {
//        @strongify(self)
//        if (!self) return;
//
//        [self requestHomePageWithAnimate:NO completion:^{
//            [weak_vc endRefresh];
//        }];
//    };
//
//    vc.endRefreshCallBack = ^{
//        @strongify(self)
//        if (!self) return;
//
//        [self.pageViewController reloadData];
//    };
//
//    return vc;
//}
//
//
//- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
//    JHBangumiCollection *model = [self bangumiCollectionWithIndex:index];
//    return model.weekDayStringValue;
//}
//
//- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
//    return CGRectMake(0, 0, self.view.width, NORMAL_SIZE_FONT.lineHeight + 20);
//}
//
//- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
//    const float menuViewHeight = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:pageController.menuView]);
//    return CGRectMake(0, menuViewHeight, self.view.width, self.view.height - menuViewHeight);
//}
//
//#pragma mark - DZNEmptyDataSetSource
//- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
//    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
//    return str;
//}
//
//- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
//    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击刷新" attributes:@{NSFontAttributeName : SMALL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
//    return str;
//}
//
//#pragma mark - DZNEmptyDataSetDelegate
//- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
//    [self requestHomePageWithAnimate:YES completion:^{
//        [self.pageViewController reloadData];
//    }];
//}
//
//#pragma mark - 私有方法
//- (JHBangumiCollection *)bangumiCollectionWithIndex:(NSInteger)index {
//    NSInteger week = [NSDate currentWeekDay];
//    if (week < 0 || week > 7) {
//        return self.model.bangumis[index];
//    }
//    index = (index + week) % self.model.bangumis.count;
//    return self.model.bangumis[index];
//}
//
//- (void)requestHomePageWithAnimate:(BOOL)animate
//                        completion:(dispatch_block_t)completion {
//    if (animate) {
//        [MBProgressHUD showLoadingInView:self.view text:nil];
//    }
//
//    [RecommedNetManager recommedInfoWithCompletionHandler:^(JHHomePage *responseObject, NSError *error) {
//        if (animate) {
//            [MBProgressHUD hideLoading];
//        }
//
//        if (error) {
//            [MBProgressHUD showWithError:error atView:self.view];
//            ((void (*)(id, SEL))(void *) objc_msgSend)((id)self.pageViewController, NSSelectorFromString(@"wm_addScrollView"));
//            UIScrollView *view = self.pageViewController.scrollView;
//            view.emptyDataSetSource = self;
//            view.emptyDataSetDelegate = self;
//            view.frame = self.view.bounds;
//            [view reloadEmptyDataSet];
//        }
//        else {
//            [responseObject.bangumis enumerateObjectsUsingBlock:^(JHBangumiCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                [obj.collection sortUsingComparator:^NSComparisonResult(JHBangumi * _Nonnull obj1, JHBangumi * _Nonnull obj2) {
//                    return obj2.isFavorite - obj1.isFavorite;
//                }];
//            }];
//            self.model = responseObject;
//        }
//
//        if (completion) {
//            completion();
//        }
//    }];
//}
//
//- (void)configRightItem {
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_search"] configAction:^(UIButton *aButton) {
//        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
//    }];
//
//    [self.navigationItem addRightItemFixedSpace:item];
//}
//
//- (void)touchRightItem:(UIButton *)button {
//    HomePageSearchViewController *vc = [[HomePageSearchViewController alloc] init];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (void)configLeftItem {
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_attention"] configAction:^(UIButton *aButton) {
//        [aButton addTarget:self action:@selector(touchLeftItem:) forControlEvents:UIControlEventTouchUpInside];
//    }];
//
//    [self.navigationItem addLeftItemFixedSpace:item];
//}
//
//- (void)touchLeftItem:(UIButton *)button {
//    if ([CacheManager shareCacheManager].user == nil) {
//        [[ToolsManager shareToolsManager] popLoginAlertViewInViewController:self];
//    }
//    else {
//        AttentionListViewController *vc = [[AttentionListViewController alloc] init];
//        vc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//}
//
//#pragma mark - 懒加载
//- (JHDefaultPageViewController *)pageViewController {
//    if (_pageViewController == nil) {
//        _pageViewController = [[JHDefaultPageViewController alloc] init];
//        _pageViewController.delegate = self;
//        _pageViewController.dataSource = self;
//        [self addChildViewController:_pageViewController];
//    }
//    return _pageViewController;
//}

@end


