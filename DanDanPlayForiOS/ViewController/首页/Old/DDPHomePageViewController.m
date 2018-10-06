//
//  DDPHomePageViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHomePageViewController.h"
#import "DDPHomePageItemViewController.h"
#import "DDPBaseWebViewController.h"
#import "DDPHomePageSearchViewController.h"
#import "DDPAttentionListViewController.h"
#import "DDPAttentionDetailViewController.h"

#import "DDPBaseWebViewController.h"
#import "DDPHomePageCollectionViewController.h"
#import "DDPAttentionListViewController.h"

#import "HomePageHeaderTableViewCell.h"
#import "DDPFeaturedTableViewCell.h"
#import "HomePageItemTableViewCell.h"
#import "HomePageBangumiProgressTableViewCell.h"

#import "MJRefreshHeader+Tools.h"
#import "NSDate+Tools.h"
#import "DDPEdgeButton.h"
#import "DDPBaseTableView.h"
#import "DDPTextHeaderView.h"
#import "DDPHomeMoreHeaderView.h"
#import <WMMenuView.h>
#import <UMSocialCore/UMSocialCore.h>
#import <UITableView+FDTemplateLayoutCell.h>

@interface DDPHomePageViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) DDPHomePage *model;
@property (strong, nonatomic) DDPBangumiQueueIntroCollection *collection;
@end

@implementation DDPHomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"首页";
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.tableView.mj_header beginRefreshing];
    [[DDPCacheManager shareCacheManager] addObserver:self forKeyPath:DDP_KEYPATH([DDPCacheManager shareCacheManager], currentUser) options:NSKeyValueObservingOptionNew context:nil];
    
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
    [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:DDP_KEYPATH([DDPCacheManager shareCacheManager], currentUser)];
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
    if (section == 0) {
        return !!self.model;
    }
    
    if (section == 1) {
        return self.collection.collection.count > 0;
    }
    
    return !!self.model.todayFeaturedModel;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HomePageHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageHeaderTableViewCell" forIndexPath:indexPath];
        @weakify(self)
        cell.touchSearchButtonCallBack = ^{
            @strongify(self)
            if (!self) return;
            
            DDPHomePageSearchViewController *vc = [[DDPHomePageSearchViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        cell.touchTimeLineButtonCallBack = ^{
            DDPHomePageCollectionViewController *vc = [[DDPHomePageCollectionViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        };
        
//        cell.didSelctedModelCallBack = ^(DDPHomeBanner *model) {
//            DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithURL:model.link];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        };
//        
//        cell.dataSource = self.model.banners;
        return cell;
    }
    
    if (indexPath.section == 1) {
        HomePageBangumiProgressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageBangumiProgressTableViewCell" forIndexPath:indexPath];
        cell.collection = self.collection;
//        @weakify(self)
//        cell.didSelectedBangumiCallBack = ^(DDPBangumiQueueIntro *model) {
//            @strongify(self)
//            if (!self) return;
//            
//            DDPAttentionDetailViewController *vc = [[DDPAttentionDetailViewController alloc] init];
//            vc.animateId = model.identity;
//            vc.isOnAir = model.isOnAir;
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        };
        
        return cell;
    }
    
    DDPFeaturedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFeaturedTableViewCell" forIndexPath:indexPath];
    cell.model = self.model.todayFeaturedModel;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    
    DDPHomeMoreHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDPHomeMoreHeaderView"];
    @weakify(self)
    if (section == 1) {
        view.titleLabel.text = @"追番进度";
        view.detailLabel.text = @"查看更多";
        view.touchCallBack = ^{
            @strongify(self)
            if (!self) return;
            
            DDPAttentionListViewController *vc = [[DDPAttentionListViewController alloc] init];
            vc.type = DDPAnimateListTypeProgress;
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        };
        view.moreImgView.image = [UIImage imageNamed:@"comment_right_arrow"];
    }
    else {
        view.touchCallBack = ^{
            @strongify(self)
            if (self.model.todayFeaturedModel.link.length == 0) return;
            
            NSURL *url = [NSURL URLWithString:self.model.todayFeaturedModel.link];
            DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithURL:url];
            vc.hidesBottomBarWhenPushed = true;
            [self.navigationController pushViewController:vc animated:true];
        };
        view.titleLabel.text = @"今日推荐";
        view.detailLabel.text = nil;
        view.moreImgView.image = [UIImage imageNamed:@"home_link"];
    }
    return view;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return HOME_PAGE_HEADER_HEIGHT;
    }
    
    if (indexPath.section == 1) {
        return 260 + (ddp_isPad() * 40);
    }
    
    return [tableView fd_heightForCellWithIdentifier:@"DDPFeaturedTableViewCell" cacheByIndexPath:indexPath configuration:^(DDPFeaturedTableViewCell *cell) {
        cell.model = self.model.todayFeaturedModel;
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    
    if (section == 1) {
        return 30 * (self.collection.collection.count > 0);
    }
    
    return 30 * !!self.model.todayFeaturedModel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
        DDPDMHYSearchConfig *config = [[DDPDMHYSearchConfig alloc] init];
        config.keyword = self.model.todayFeaturedModel.name;
        
        DDPHomePageSearchViewController *vc = [[DDPHomePageSearchViewController alloc] init];
        vc.config = config;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
        
//        if (self.model.todayFeaturedModel.link.length) {
//            NSURL *url = [NSURL URLWithString:self.model.todayFeaturedModel.link];
//            DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithURL:url];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
    }
}

#pragma mark - 私有方法
- (void)configLeftItem {
    
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        [_tableView registerClass:[DDPTextHeaderView class] forHeaderFooterViewReuseIdentifier:@"DDPTextHeaderView"];
        [_tableView registerClass:[HomePageHeaderTableViewCell class] forCellReuseIdentifier:@"HomePageHeaderTableViewCell"];
        [_tableView registerClass:[HomePageBangumiProgressTableViewCell class] forCellReuseIdentifier:@"HomePageBangumiProgressTableViewCell"];
        [_tableView registerNib:[DDPFeaturedTableViewCell loadNib] forCellReuseIdentifier:@"DDPFeaturedTableViewCell"];
        [_tableView registerClass:[DDPHomeMoreHeaderView class] forHeaderFooterViewReuseIdentifier:@"DDPHomeMoreHeaderView"];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            [DDPRecommedNetManagerOperation recommedInfoWithCompletionHandler:^(DDPHomePage *responseObject, NSError *error) {
                
                if (error) {
                    [self.view showWithError:error];
                }
                else {
                    self.model = responseObject;
                    [self.tableView reloadData];
                }
                
                [self.tableView endRefreshing];
            }];
            
            if ([DDPCacheManager shareCacheManager].currentUser.isLogin) {
                [DDPPlayHistoryNetManagerOperation playHistoryWithUser:[DDPCacheManager shareCacheManager].currentUser completionHandler:^(DDPBangumiQueueIntroCollection *responseObject, NSError *error) {
                    if (error) {
                        [self.view showWithError:error];
                    }
                    else {
                        self.collection = responseObject;
                        [self.tableView reloadData];
                    }
                }];
            }
            else {
                self.collection = nil;
                [self.tableView reloadData];
            }
        }];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end


