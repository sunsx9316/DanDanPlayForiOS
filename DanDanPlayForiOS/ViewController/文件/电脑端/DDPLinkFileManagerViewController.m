//
//  LinkDDPFileManagerViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLinkFileManagerViewController.h"
#import "DDPMatchViewController.h"
#import "DDPPlayNavigationController.h"
#import "DDPFileManagerViewController.h"
#import "DDPQRScannerViewController.h"

#import "DDPLinkFileTableViewCell.h"
#import "DDPFileManagerFolderLongViewCell.h"
#import "DDPBaseTableView.h"
#import "DDPEdgeButton.h"

@interface DDPLinkFileManagerViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, DDPCacheManagerDelagate>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) UIImage *folderImg;
@end

@implementation DDPLinkFileManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self configRightItem];
    [[DDPCacheManager shareCacheManager] addObserver:self];
    
    if (ddp_isRootFile(self.file)) {
        self.navigationItem.title = @"根目录";
        [self.tableView.mj_header beginRefreshing];
    }
    else {
        self.navigationItem.title = _file.name;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DDPCacheManager shareCacheManager] removeObserver:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([DDPCacheManager shareCacheManager].linkInfo) {
        if (self.tableView.mj_header.refreshingBlock) {
            self.tableView.mj_header.refreshingBlock();
        }
    }
    else {
        [self.tableView endRefreshing];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _file.subFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPLinkFile *file = _file.subFiles[indexPath.row];
    
    if (file.type == DDPFileTypeDocument) {
        DDPLinkFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPLinkFileTableViewCell" forIndexPath:indexPath];
        cell.model = file;
        return cell;
    }
    
    DDPFileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileManagerFolderLongViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.name;
    cell.detailLabel.text = [NSString stringWithFormat:@"%lu个视频", (unsigned long)file.subFiles.count];
    cell.iconImgView.image = self.folderImg;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPFile *file = _file.subFiles[indexPath.row];
    if (file.type == DDPFileTypeFolder) {
        return 80 + 40 * ddp_isPad();
    }
    return 100 + 40 * ddp_isPad();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DDPLinkFile *file = _file.subFiles[indexPath.row];
    
    if (file.type == DDPFileTypeDocument) {
        DDPVideoModel *model = file.videoModel;
        [self tryAnalyzeVideo:model];
    }
    else if (file.type == DDPFileTypeFolder) {
        DDPLinkFileManagerViewController *vc = [[DDPLinkFileManagerViewController alloc] init];
        vc.file = file;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if ([DDPCacheManager shareCacheManager].linkInfo) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        return str;
    }
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"还没有连接到电脑端~" attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if ([DDPCacheManager shareCacheManager].linkInfo) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击刷新" attributes:@{NSFontAttributeName : [UIFont ddp_smallSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        return str;
    }
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击扫码连接" attributes:@{NSFontAttributeName : [UIFont ddp_smallSizeFont], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.tableView.showEmptyView;
}

- (void)emptyDataSet:(UITableView *)scrollView didTapView:(UIView *)view {
    if ([DDPCacheManager shareCacheManager].linkInfo) {
        [scrollView.mj_header beginRefreshing];
    }
    else {
        DDPQRScannerViewController *vc = [[DDPQRScannerViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return self.tableView.allowScroll;
}

#pragma mark - DDPCacheManagerDelagate
- (void)lastPlayTimeWithVideoModel:(DDPVideoModel *)videoModel time:(NSInteger)time {
    [self.tableView reloadData];
}

#pragma mark - 私有方法

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_qr_code"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)sender {
    DDPQRScannerViewController *vc = [[DDPQRScannerViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    @weakify(self)
    vc.linkSuccessCallBack = ^(DDPLinkInfo *info) {
        @strongify(self)
        if (!self) return;
        
        NSMutableArray *arr = [self.navigationController.viewControllers mutableCopy];
        [arr removeLastObject];
        
        
        //连接成功直接跳转到列表
        DDPLinkFileManagerViewController *avc = [[DDPLinkFileManagerViewController alloc] init];
        avc.file = ddp_getANewLinkRootFile();
        avc.hidesBottomBarWhenPushed = YES;
        [arr addObject:avc];
        [self.navigationController setViewControllers:arr animated:YES];
    };
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[DDPLinkFileTableViewCell class] forCellReuseIdentifier:@"DDPLinkFileTableViewCell"];
        [_tableView registerClass:[DDPFileManagerFolderLongViewCell class] forCellReuseIdentifier:@"DDPFileManagerFolderLongViewCell"];
        
        if (ddp_isRootFile(self.file)) {
            @weakify(self)
            _tableView.mj_header = [MJRefreshHeader ddp_headerRefreshingCompletionHandler:^{
                @strongify(self)
                if (!self) return;
                
                DDPLinkInfo *info = [DDPCacheManager shareCacheManager].linkInfo ?: [DDPCacheManager shareCacheManager].lastLinkInfo;
                
                [[DDPToolsManager shareToolsManager] startDiscovererFileWithLinkParentFile:self.file linkInfo:info completion:^(DDPLinkFile *file, NSError *error) {
                    if (error) {
                        [self.view showWithError:error];
                    }
                    else {
                        self.file = file;
                        [self.tableView reloadData];
                    }
                    
                    [self.tableView endRefreshing];
                }];
            }];
        }
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (UIImage *)folderImg {
    if (_folderImg == nil) {
        _folderImg = [[UIImage imageNamed:@"comment_local_file_folder"] renderByMainColor];
    }
    return _folderImg;
}

@end
