//
//  DDPHomePageItemViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHomePageItemViewController.h"
#import "DDPBaseWebViewController.h"
#import "DDPHomePageSearchViewController.h"
#import "DDPAttentionDetailViewController.h"

#import "DDPBaseTableView.h"
#import "HomePageItemTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "NSString+Tools.h"

@interface DDPHomePageItemViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@end

@implementation DDPHomePageItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cancelAttention:) name:ATTENTION_SUCCESS_NOTICE object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)endRefresh {
    [self.tableView endRefreshing];
}

- (void)setBangumis:(NSArray<DDPHomeBangumi *> *)bangumis {
    _bangumis = bangumis;
    [self resortBangumis];
    if (self.isViewLoaded) {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bangumis.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomePageItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageItemTableViewCell" forIndexPath:indexPath];
    DDPHomeBangumi *model = self.bangumis[indexPath.row];
    cell.model = model;
    @weakify(self)
    cell.touchLikeCallBack = ^(DDPHomeBangumi *aModel) {
        @strongify(self)
        if (!self) return;
        
        DDPUser *user = [DDPCacheManager shareCacheManager].user;
        [self.view showLoadingWithText:@"请求中..."];
        [DDPFavoriteNetManagerOperation favoriteLikeWithUser:user animeId:aModel.identity like:!aModel.isFavorite completionHandler:^(NSError *error) {
            [self.view hideLoading];
            
            if (error) {
                [self.view showWithError:error];
            }
            else {
                aModel.isFavorite = !aModel.isFavorite;
                [self resortBangumis];
                [self.tableView reloadData];
            }
        }];
    };
    
    cell.selectedItemCallBack = ^(DDPHomeBangumiSubtitleGroup *aModel) {
        @strongify(self)
        if (!self) return;
        
        DDPDMHYParse *parseModel = [aModel parseModel];
        
        DDPHomePageSearchViewController *vc = [[DDPHomePageSearchViewController alloc] init];
        DDPDMHYSearchConfig *config = [[DDPDMHYSearchConfig alloc] init];
        config.keyword = model.name;
        config.subGroupId = parseModel.identity;
        config.link = parseModel.link;
        vc.config = config;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPHomeBangumi *model = self.bangumis[indexPath.row];
    
    DDPAttentionDetailViewController *vc = [[DDPAttentionDetailViewController alloc] init];
    vc.animateId = model.identity;
    vc.isOnAir = YES;
    @weakify(self)
    vc.attentionCallBack = ^(NSUInteger animateId) {
        @strongify(self)
        if (!self) return;
        
        model.isFavorite = YES;
        [self resortBangumis];
        [self.tableView reloadData];
    };
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 私有方法
- (void)cancelAttention:(NSNotification *)aSender {
    NSInteger animateId = [aSender.object integerValue];
    BOOL attention = [aSender.userInfo[ATTENTION_SUCCESS_NOTICE] boolValue];
    [self.bangumis enumerateObjectsUsingBlock:^(DDPHomeBangumi * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.identity == animateId) {
            obj.isFavorite = attention;
            [self resortBangumis];
            [self.tableView reloadData];
            *stop = YES;
        }
    }];
}

- (void)resortBangumis {
    [(NSMutableArray *)self.bangumis sortUsingComparator:^NSComparisonResult(DDPHomeBangumi * _Nonnull obj1, DDPHomeBangumi * _Nonnull obj2) {
        if (obj2.isFavorite == obj1.isFavorite) {
            return [obj1.name compare:obj2.name];
        }
        return obj2.isFavorite - obj1.isFavorite;
    }];
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = ITEM_CELL_HEIGHT + 20;
        [_tableView registerClass:[HomePageItemTableViewCell class] forCellReuseIdentifier:@"HomePageItemTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:self.handleBannerCallBack];
        header.endRefreshingCompletionBlock = self.endRefreshCallBack;
        _tableView.mj_header = header;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
