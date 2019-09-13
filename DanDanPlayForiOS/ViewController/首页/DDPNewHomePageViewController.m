//
//  DDPNewHomePageViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/3.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewHomePageViewController.h"
#import "DDPNewHomePageItemViewController.h"
#import "DDPAttentionListViewController.h"
#import "MJRefreshHeader+Tools.h"
#import "DDPHomePageBannerCollectionViewCell.h"
#import "DDPHomePageBannerView.h"
#import "HomePageBangumiProgressTableViewCell.h"
#import "DDPHomeMoreHeaderView.h"
#import "DDPHomeBangumiIntroHeaderView.h"
#import "DDPPlayerSelectedIndexView.h"

#define IN_SERIA_TEXT @"连载中"

@interface DDPNewHomePageViewController ()<DDPCacheManagerDelagate, DDPPlayerSelectedIndexViewDelegate, DDPPlayerSelectedIndexViewDataSource>
@property (strong, nonatomic) DDPNewHomePage *model;

@property (strong, nonatomic) NSDictionary <NSString *, NSArray <DDPNewBangumiIntro *>*>*bangumiDic;
@property (strong, nonatomic) DDPNewBangumiSeason *season;

@property (strong, nonatomic) DDPHomePageBannerView *bannerView;
@property (strong, nonatomic) DDPHomeMoreHeaderView *progressHeaderView;
@property (strong, nonatomic) HomePageBangumiProgressTableViewCell *bangumiProgressView;

@property (strong, nonatomic) DDPHomeBangumiIntroHeaderView *bangumiIntroHeaderView;
/**
 追番进度
 */
@property (strong, nonatomic) DDPBangumiQueueIntroCollection *progressCollection;

@property (strong, nonatomic) DDPUser *user;


/**
 当前选择的番剧日期 Nil则为连载中
 */
@property (strong, nonatomic) DDPNewBangumiSeason *currentBangumiSeason;

@property (weak, nonatomic) DDPPlayerSelectedIndexView *selectedIndexView;
@end

@implementation DDPNewHomePageViewController
{
    NSArray <NSString *>*_sortKeys;
}

- (instancetype)init {
    if (self = [super init]) {
        self.menuViewHeight = 40;
        self.itemMargin = 15;
        self.menuViewContentMargin = -5;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.user = [DDPCacheManager shareCacheManager].currentUser;
    
    [[DDPCacheManager shareCacheManager] addObserver:self];
    
    [self.view addSubview:self.bannerView];
    [self.view addSubview:self.progressHeaderView];
    [self.view addSubview:self.bangumiProgressView];
    [self.view addSubview:self.bangumiIntroHeaderView];
    
    @weakify(self)
    self.contentView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
        @strongify(self)
        if (!self) {
            return;
        }
        
        [DDPRecommedNetManagerOperation homePageWithCompletionHandler:^(DDPNewHomePage *model, NSError *error) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self.contentView.mj_header endRefreshing];
            
            if (error) {
                //                [self.view showWithError:error];
            }
            else {
                self.model = model;
                self.bannerView.models = model.banners;
                self.currentBangumiSeason = self.currentBangumiSeason;
            }
        }];
        
        
        if (self.user.isLogin) {
            [DDPPlayHistoryNetManagerOperation playHistoryWithUser:self.user completionHandler:^(DDPBangumiQueueIntroCollection *responseObject, NSError *error) {
                if (error) {
                    //                    [self.view showWithError:error];
                }
                else {
                    self.progressCollection = responseObject;
                    self.bangumiProgressView.collection = responseObject;
                }
                [self reloadData];
            }];
        }
        else {
            self.progressCollection = nil;
            [self reloadData];
        }
    }];
    
    [self.contentView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeAttention:) name:ATTENTION_SUCCESS_NOTICE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefresh) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self headerRefresh];
}


- (void)dealloc {
    [[DDPCacheManager shareCacheManager] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    let size = self.view.size;
    self.bannerView.frame = CGRectMake(0, 0, size.width, HOME_BANNER_VIEW_HEIGHT);
    
    self.progressHeaderView.frame = CGRectMake(0, self.bannerView.bottom, size.width, [self progressHeaderHeight]);
    self.bangumiProgressView.frame = CGRectMake(0, self.progressHeaderView.bottom, size.width, [self progressViewHeight]);
    self.bangumiIntroHeaderView.frame = CGRectMake(0, self.bangumiProgressView.bottom, size.width, [self bangumiIntroHeaderHeight]);
}


- (void)reloadData {
    
    CGFloat progressHeight = [self progressViewHeight];
    CGFloat progressHeaderHeight = [self progressHeaderHeight];
    CGFloat bangumiIntroHeaderHeight = [self bangumiIntroHeaderHeight];
    
    self.maximumHeaderViewHeight = HOME_BANNER_VIEW_HEIGHT + progressHeight + progressHeaderHeight + bangumiIntroHeaderHeight;
    
    [super reloadData];
}

#pragma mark - DDPCacheManagerDelagate
- (void)userLoginStatusDidChange:(DDPUser *)user {
    self.user = user;
    if (self.contentView.mj_header.refreshingBlock) {
        self.contentView.mj_header.refreshingBlock();
    }
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return _sortKeys.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    DDPNewHomePageItemViewController *vc = [[DDPNewHomePageItemViewController alloc] init];
    vc.bangumis = self.bangumiDic[_sortKeys[index]];
    return vc;
}


- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return _sortKeys[index];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGRect preferredFrameForMenuView = [self pageController:pageController preferredFrameForMenuView:pageController.menuView];
    return CGRectMake(0,
                      CGRectGetMaxY(preferredFrameForMenuView),
                      CGRectGetWidth(preferredFrameForMenuView),
                      CGRectGetHeight(self.view.frame) -
                      self.minimumHeaderViewHeight -
                      CGRectGetHeight(preferredFrameForMenuView));
    
}

#pragma mark - DDPPlayerSelectedIndexViewDataSource
- (NSInteger)indexView:(DDPPlayerSelectedIndexView *)view numbeOfRowInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    return self.model.bangumiSeasons.count;
}

- (NSInteger)numbeOfSectionInIndexView:(DDPPlayerSelectedIndexView *)view {
    return 2;
}

- (NSString * _Nullable)indexView:(DDPPlayerSelectedIndexView *)view titleAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return IN_SERIA_TEXT;
    }
    return self.model.bangumiSeasons[indexPath.row].name;
}

#pragma mark - DDPCacheManagerDelagate
- (void)selectedIndexView:(DDPPlayerSelectedIndexView *)view didSelectedIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.currentBangumiSeason = nil;
    }
    else {
        self.currentBangumiSeason = self.model.bangumiSeasons[indexPath.row];
    }
    
    [self.selectedIndexView dismiss];
}

- (NSIndexPath * _Nullable)selectedIndexPathForIndexView {
    if (self.currentBangumiSeason == nil) {
        return [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    NSInteger index = [self.model.bangumiSeasons indexOfObject:self.currentBangumiSeason];
    if (index != NSNotFound) {
        return [NSIndexPath indexPathForRow:index inSection:1];
    }
    return nil;
}


#pragma mark - 私有方法
- (void)resetBangumiDicWithShinBangumiList:(NSArray <DDPNewBangumiIntro *>*)shinBangumiList {
    NSMutableArray <NSString *>*tempArr = [NSMutableArray arrayWithObject:[self mapKeyWithWeekday:-1]];
    
    if (self.user.isLogin == false) {
        [tempArr removeAllObjects];
    }
    
    NSDate *date = [NSDate date];
    for (NSInteger i = 0; i < 7; ++i) {
        NSString *day = [self mapKeyWithWeekday:[date dateByAddingDays:i].weekday - 1];
        [tempArr addObject:day];
    }
    _sortKeys = tempArr;
    
    
    NSMutableDictionary <NSString *, NSMutableArray <DDPNewBangumiIntro *>*>*dic = [NSMutableDictionary dictionary];
    
    
    let getArrAction = ^NSMutableArray <DDPNewBangumiIntro *>*(NSInteger index) {
        let mapKey = [self mapKeyWithWeekday:index];
        var arr = dic[mapKey];
        if (arr == nil) {
            arr = [NSMutableArray array];
            dic[mapKey] = arr;
        }
        return arr;
    };
    
    [shinBangumiList enumerateObjectsUsingBlock:^(DDPNewBangumiIntro * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isFavorited) {
            let arr = getArrAction(-1);
            [arr addObject:obj];
        }
        
        
        NSInteger week = obj.airDay;
        let arr = getArrAction(week);
        [arr addObject:obj];
    }];
    
    self.bangumiDic = dic;
}

- (NSString *)mapKeyWithWeekday:(NSInteger)weekday {
    switch (weekday) {
        case -1:
            return @"我的关注";
        case 0:
            return @"周日";
        case 1:
            return @"周一";
        case 2:
            return @"周二";
        case 3:
            return @"周三";
        case 4:
            return @"周四";
        case 5:
            return @"周五";
        case 6:
            return @"周六";
        default:
            return @"";
    }
}

- (void)changeAttention:(NSNotification *)aSender {
    if (self.contentView.mj_header.refreshingBlock) {
        self.contentView.mj_header.refreshingBlock();
    }
}

- (CGFloat)progressHeaderHeight {
    CGFloat progressHeaderHeight = 40 * (self.progressCollection.collection.count > 0) * self.user.isLogin;
    return progressHeaderHeight;
}

- (CGFloat)progressViewHeight {
    CGFloat progressHeight = (245 + (ddp_isPad() * 40)) * self.user.isLogin * (self.progressCollection.collection.count > 0);
    if (ddp_appType == DDPAppTypeToMac) {
        return progressHeight + 50;
    }
    return progressHeight;
}

- (CGFloat)bangumiIntroHeaderHeight {
    CGFloat progressHeaderHeight = 40 * (self.bangumiDic.count > 0);
    return progressHeaderHeight;
}

- (void)setCurrentBangumiSeason:(DDPNewBangumiSeason *)currentBangumiSeason {
    _currentBangumiSeason = currentBangumiSeason;
    if (_currentBangumiSeason == nil) {
        self.bangumiIntroHeaderView.titleLabel.text = IN_SERIA_TEXT;
        [self resetBangumiDicWithShinBangumiList:self.model.shinBangumiList];
        [self reloadData];
    }
    else {
        let model = currentBangumiSeason;
        @weakify(self)
        [self.view showLoading];
        [DDPBangumiNetManagerOperation seasonListWithYear:model.year month:model.month completionHandler:^(DDPNewBangumiIntroCollection * _Nonnull collection, NSError * _Nonnull error) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self.view hideLoading];
            
            if (error) {
                [self.view showWithError:error];
            }
            else {
                self.bangumiIntroHeaderView.titleLabel.text = model.name;
                [self resetBangumiDicWithShinBangumiList:collection.collection];
                [self reloadData];
            }
        }];
    }
}

- (void)showBangumiSeasonList {
    DDPPlayerSelectedIndexView *view = [DDPPlayerSelectedIndexView fromXib];
    view.effect = nil;
    view.contentViewBgColor = [UIColor whiteColor];
    view.textColor = [UIColor darkGrayColor];
    view.delegate = self;
    view.dataSource = self;
    [view show];
    self.selectedIndexView = view;
}

- (void)headerRefresh {
    //fix 有时候首页会空白的问题
    if (self.contentView.mj_header.isRefreshing == false && self.contentView.mj_header.refreshingBlock && self.model == nil) {
        self.contentView.mj_header.refreshingBlock();
    }
}

#pragma mark - 懒加载
- (DDPHomePageBannerView *)bannerView {
    if (_bannerView == nil) {
        _bannerView = [[DDPHomePageBannerView alloc] init];
    }
    return _bannerView;
}

- (HomePageBangumiProgressTableViewCell *)bangumiProgressView {
    if (_bangumiProgressView == nil) {
        _bangumiProgressView = [[HomePageBangumiProgressTableViewCell alloc] init];
    }
    return _bangumiProgressView;
}

- (DDPHomeMoreHeaderView *)progressHeaderView {
    if (_progressHeaderView == nil) {
        _progressHeaderView = [[DDPHomeMoreHeaderView alloc] initWithReuseIdentifier:nil];
        _progressHeaderView.titleLabel.text = @"追番进度";
        _progressHeaderView.clipsToBounds = true;
        _progressHeaderView.backgroundColor = [UIColor whiteColor];
        @weakify(self)
        _progressHeaderView.touchCallBack = ^{
            @strongify(self)
            if (!self) return;
            
            DDPAttentionListViewController *vc = [[DDPAttentionListViewController alloc] init];
            vc.type = DDPAnimateListTypeProgress;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        };
    }
    return _progressHeaderView;
}

- (DDPHomeBangumiIntroHeaderView *)bangumiIntroHeaderView {
    if (_bangumiIntroHeaderView == nil) {
        _bangumiIntroHeaderView = [[DDPHomeBangumiIntroHeaderView alloc] initWithReuseIdentifier:nil];
        _bangumiIntroHeaderView.backgroundColor = [UIColor whiteColor];
        _bangumiIntroHeaderView.clipsToBounds = true;
        @weakify(self)
        _bangumiIntroHeaderView.touchHeaderCallBack = ^{
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self showBangumiSeasonList];
        };
    }
    return _bangumiIntroHeaderView;
}

@end
