//
//  LinkFileManagerViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LinkFileManagerViewController.h"
#import "MatchViewController.h"
#import "PlayNavigationController.h"
#import "FileManagerViewController.h"
#import "QRScanerViewController.h"

#import "LinkFileTableViewCell.h"
#import "FileManagerFolderLongViewCell.h"
#import "BaseTableView.h"
#import "JHEdgeButton.h"

@interface LinkFileManagerViewController ()<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (strong, nonatomic) BaseTableView *tableView;
@end

@implementation LinkFileManagerViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: MAIN_COLOR, NSFontAttributeName : NORMAL_SIZE_FONT};
    
    if (jh_isRootFile(self.file)) {
        [self setNavigationBarWithColor:[UIColor clearColor]];
    }
    else {
        [self setNavigationBarWithColor:[UIColor whiteColor]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (jh_isRootFile(self.file)) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        [self refresh];
    }
    else {
        self.automaticallyAdjustsScrollViewInsets = YES;
        self.navigationItem.title = _file.name;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _file.subFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHLinkFile *file = _file.subFiles[indexPath.row];
    
    if (file.type == JHFileTypeDocument) {
        LinkFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LinkFileTableViewCell" forIndexPath:indexPath];
        cell.model = file.library;
        return cell;
    }
    
    FileManagerFolderLongViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileManagerFolderLongViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = file.name;
    cell.detailLabel.text = [NSString stringWithFormat:@"%lu个视频", (unsigned long)file.subFiles.count];
    cell.iconImgView.image = [UIImage imageNamed:@"local_file_folder"];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHFile *file = _file.subFiles[indexPath.row];
    if (file.type == JHFileTypeFolder) {
        return 80 + 40 * jh_isPad();
    }
    return 100 + 40 * jh_isPad();
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JHLinkFile *file = _file.subFiles[indexPath.row];
    
    if (file.type == JHFileTypeDocument) {
        VideoModel *model = file.videoModel;
        void(^jumpToMatchVCAction)(void) = ^{
            MatchViewController *vc = [[MatchViewController alloc] init];
            vc.model = model;
            vc.hidesBottomBarWhenPushed = YES;
            [self.parentViewController.navigationController pushViewController:vc animated:YES];
        };
        
        if ([CacheManager shareCacheManager].openFastMatch) {
            MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
            [MatchNetManager fastMatchVideoModel:model progressHandler:^(float progress) {
                aHUD.progress = progress;
                aHUD.label.text = jh_danmakusProgressToString(progress);
            } completionHandler:^(JHDanmakuCollection *responseObject, NSError *error) {
                model.danmakus = responseObject;
                [aHUD hideAnimated:NO];
                
                if (responseObject == nil) {
                    jumpToMatchVCAction();
                }
                else {
                    PlayNavigationController *nav = [[PlayNavigationController alloc] initWithModel:model];
                    [self presentViewController:nav animated:YES completion:nil];
                }
            }];
        }
        else {
            jumpToMatchVCAction();
        }
        
    }
    else if (file.type == JHFileTypeFolder) {
        LinkFileManagerViewController *vc = [[LinkFileManagerViewController alloc] init];
        vc.file = file;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - DZNEmptyDataSetSource
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if ([CacheManager shareCacheManager].linkInfo) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"暂无数据" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        return str;
    }
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"还没有连接到电脑端~" attributes:@{NSFontAttributeName : NORMAL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if ([CacheManager shareCacheManager].linkInfo) {
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击刷新" attributes:@{NSFontAttributeName : SMALL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
        return str;
    }
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"点击扫码连接" attributes:@{NSFontAttributeName : SMALL_SIZE_FONT, NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    return str;
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.tableView.showEmptyView;
}

- (void)emptyDataSet:(UITableView *)scrollView didTapView:(UIView *)view {
    if ([CacheManager shareCacheManager].linkInfo) {
        [scrollView.mj_header beginRefreshing];
    }
    else {
        QRScanerViewController *vc = [[QRScanerViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.parentViewController.navigationController pushViewController:vc animated:YES];
    }
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return self.tableView.allowScroll;
}

#pragma mark - 私有方法
- (void)configLeftItem {
    if (jh_isRootFile(self.file) == NO) {
        UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"back_item"] yy_imageByTintColor:MAIN_COLOR] configAction:^(UIButton *aButton) {
            [aButton addTarget:self action:@selector(touchLeftItem:) forControlEvents:UIControlEventTouchUpInside];
        }];
        
        [self.navigationItem addLeftItemFixedSpace:item];
    }
}

- (void)refresh {
    if ([CacheManager shareCacheManager].linkInfo) {
        if (self.tableView.mj_header.refreshingBlock) {
            self.tableView.mj_header.refreshingBlock();
        }
    }
    else {
        [self.tableView endRefreshing];
    }
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[LinkFileTableViewCell class] forCellReuseIdentifier:@"LinkFileTableViewCell"];
        [_tableView registerClass:[FileManagerFolderLongViewCell class] forCellReuseIdentifier:@"FileManagerFolderLongViewCell"];
        
        if (jh_isRootFile(self.file)) {
            @weakify(self)
            _tableView.mj_header = [MJRefreshHeader jh_headerRefreshingCompletionHandler:^{
                @strongify(self)
                if (!self) return;
                
                [[ToolsManager shareToolsManager] startDiscovererFileWithLinkParentFile:self.file completion:^(JHLinkFile *file, NSError *error) {
                    if (error) {
                        [MBProgressHUD showWithError:error];
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


@end
