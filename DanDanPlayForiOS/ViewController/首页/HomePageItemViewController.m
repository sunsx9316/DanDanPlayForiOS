//
//  HomePageItemViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageItemViewController.h"
#import "JHBaseWebViewController.h"
#import "HomePageSearchViewController.h"
#import "AttentionDetailViewController.h"

#import "JHBaseTableView.h"
#import "HomePageItemTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "NSString+Tools.h"

@interface HomePageItemViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) JHBaseTableView *tableView;
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

- (void)setBangumis:(NSArray<JHHomeBangumi *> *)bangumis {
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
    JHHomeBangumi *model = self.bangumis[indexPath.row];
    cell.model = model;
    @weakify(self)
    cell.touchLikeCallBack = ^(JHHomeBangumi *aModel) {
        @strongify(self)
        if (!self) return;
        
        JHUser *user = [CacheManager shareCacheManager].user;
        [MBProgressHUD showLoadingInView:self.view text:@"请求中..."];
        [FavoriteNetManager favoriteLikeWithUser:user animeId:aModel.identity like:!aModel.isFavorite completionHandler:^(NSError *error) {
            [MBProgressHUD hideLoading];
            
            if (error) {
                [MBProgressHUD showWithError:error atView:self.view];
            }
            else {
                aModel.isFavorite = !aModel.isFavorite;
                [self resortBangumis];
                [self.tableView reloadData];
            }
        }];
    };
    
    cell.selectedItemCallBack = ^(JHHomeBangumiSubtitleGroup *aModel) {
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

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JHHomeBangumi *model = self.bangumis[indexPath.row];
    
    AttentionDetailViewController *vc = [[AttentionDetailViewController alloc] init];
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
    [self.bangumis enumerateObjectsUsingBlock:^(JHHomeBangumi * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.identity == animateId) {
            obj.isFavorite = attention;
            [self resortBangumis];
            [self.tableView reloadData];
            *stop = YES;
        }
    }];
}

- (void)resortBangumis {
    [(NSMutableArray *)self.bangumis sortUsingComparator:^NSComparisonResult(JHHomeBangumi * _Nonnull obj1, JHHomeBangumi * _Nonnull obj2) {
        return obj2.isFavorite - obj1.isFavorite;
    }];
}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = ITEM_CELL_HEIGHT + 20;
        [_tableView registerClass:[HomePageItemTableViewCell class] forCellReuseIdentifier:@"HomePageItemTableViewCell"];
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:self.handleBannerCallBack];
        header.endRefreshingCompletionBlock = self.endRefreshCallBack;
        _tableView.mj_header = header;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
