//
//  HomePageItemViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageItemViewController.h"
#import "WebViewController.h"
#import "HomePageSearchViewController.h"
#import "AttentionDetailViewController.h"

#import "BaseTableView.h"
#import "HomePageItemTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "NSString+Tools.h"

@interface HomePageItemViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) BaseTableView *tableView;
@end

@implementation HomePageItemViewController

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

- (void)setBangumis:(NSArray<JHBangumi *> *)bangumis {
    _bangumis = bangumis;
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
    cell.model = self.bangumis[indexPath.row];
    @weakify(self)
    cell.touchLikeCallBack = ^(JHBangumi *model) {
        @strongify(self)
        if (!self) return;
        
        JHUser *user = [CacheManager shareCacheManager].user;
        [MBProgressHUD showLoadingInView:self.view text:@"请求中..."];
        [FavoriteNetManager favoriteLikeWithUser:user animeId:model.identity like:!model.isFavorite completionHandler:^(NSError *error) {
            [MBProgressHUD hideLoading];
            
            if (error) {
                [MBProgressHUD showWithError:error atView:self.view];
            }
            else {
                model.isFavorite = !model.isFavorite;
                [self resortBangumis];
                [self.tableView reloadData];
            }
        }];
    };
    
    cell.selectedItemCallBack = ^(JHBangumiGroup *model) {
        @strongify(self)
        if (!self) return;
        
        JHDMHYParse *parseModel = [model.link parseModel];
        
        HomePageSearchViewController *vc = [[HomePageSearchViewController alloc] init];
        JHDMHYSearchConfig *config = [[JHDMHYSearchConfig alloc] init];
        config.keyword = parseModel.name;
        config.subGroupId = parseModel.identity;
        vc.config = config;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JHBangumi *model = self.bangumis[indexPath.row];
    
    AttentionDetailViewController *vc = [[AttentionDetailViewController alloc] init];
    vc.animateId = model.identity;
    vc.isOnAir = YES;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 私有方法
- (void)cancelAttention:(NSNotification *)aSender {
    NSInteger animateId = [aSender.object integerValue];
    BOOL attention = [aSender.userInfo[ATTENTION_SUCCESS_NOTICE] boolValue];
    [self.bangumis enumerateObjectsUsingBlock:^(JHBangumi * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.identity == animateId) {
            obj.isFavorite = attention;
            [self resortBangumis];
            [self.tableView reloadData];
            *stop = YES;
        }
    }];
}

- (void)resortBangumis {
    [(NSMutableArray *)self.bangumis sortUsingComparator:^NSComparisonResult(JHBangumi * _Nonnull obj1, JHBangumi * _Nonnull obj2) {
        return obj2.isFavorite - obj1.isFavorite;
    }];
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 100;
        [_tableView registerClass:[HomePageItemTableViewCell class] forCellReuseIdentifier:@"HomePageItemTableViewCell"];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:self.handleBannerCallBack];
        header.endRefreshingCompletionBlock = self.endRefreshCallBack;
        _tableView.mj_header = header;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
