//
//  HomePageItemViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageItemViewController.h"
#import "WebViewController.h"

#import "BaseTableView.h"
#import "HomePageItemTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>

@interface HomePageItemViewController ()<UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) BaseTableView *tableView;
@end

@implementation HomePageItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
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
        
        NSLog(@"%d", model.isFavorite);
    };
    
    cell.selectedItemCallBack = ^(JHBangumiGroup *model) {
        @strongify(self)
        if (!self) return;
        
        WebViewController *vc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:model.link]];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JHBangumi *model = self.bangumis[indexPath.row];
    
    WebViewController *vc = [[WebViewController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://share.dmhy.org/topics/list?keyword=%@", [model.keyword stringByURLEncode]]]];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    CGPoint point = [scrollView.panGestureRecognizer velocityInView:scrollView];
    if (point.y < 0) {
        if (self.handleBannerCallBack) {
            self.handleBannerCallBack(NO);
        }
    }
    NSLog(@"%@", NSStringFromCGPoint(point));
}


#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 90;
        [_tableView registerClass:[HomePageItemTableViewCell class] forCellReuseIdentifier:@"HomePageItemTableViewCell"];
        @weakify(self)
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            if (self.handleBannerCallBack) {
                self.handleBannerCallBack(YES);
            }
            
            [self.tableView.mj_header endRefreshing];
        }];
        [header setTitle:@"显示会滚动的咨询" forState:MJRefreshStateIdle];
        [header setTitle:@"好想看" forState:MJRefreshStatePulling];
        _tableView.mj_header = header;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
