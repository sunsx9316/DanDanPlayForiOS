//
//  LocalFileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LocalFileViewController.h"
#import "MatchViewController.h"
#import "PlayNavigationController.h"
#import "HTTPServerViewController.h"
#import "RemoteSelectedView.h"
#import "SMBViewController.h"

#import "JHEdgeButton.h"
#import "FileManagerView.h"

@interface LocalFileViewController ()<UISearchBarDelegate, FileManagerViewDelegate>
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) FileManagerView *fileManagerView;
@end

@implementation LocalFileViewController
{
    JHFile *_currentFile;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reload) name:COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE object:nil];
    
    _currentFile = [CacheManager shareCacheManager].rootFile;
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(SEARCH_BAR_HEIRHT);
    }];
    
    [self.fileManagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.searchBar.mas_bottom);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        self.fileManagerView.searchKey = nil;
    }
    else {
        self.fileManagerView.searchKey = searchText;
    }
}

#pragma mark - FileManagerViewDelegate
- (void)managerView:(FileManagerView *)managerView didselectedModel:(JHFile *)file {
    VideoModel *model = file.videoModel;
    void(^jumpToMatchVCAction)() = ^{
        MatchViewController *vc = [[MatchViewController alloc] init];
        vc.model = model;
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    };

    if ([CacheManager shareCacheManager].openFastMatch) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
        [MatchNetManager fastMatchVideoModel:model progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = danmakusProgressToString(progress);
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

#pragma mark - 私有方法
- (void)reload {
    [self.fileManagerView refreshingWithAnimate:NO];
}

- (void)configLeftItem {
    
}

#pragma mark - 懒加载
- (UISearchBar *)searchBar {
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, SEARCH_BAR_HEIRHT)];
        _searchBar.placeholder = @"搜索文件名";
        _searchBar.delegate = self;
        [self.view addSubview:_searchBar];
    }
    return _searchBar;
}

- (FileManagerView *)fileManagerView {
    if (_fileManagerView == nil) {
        _fileManagerView = [[FileManagerView alloc] initWithFrame:CGRectMake(0, self.searchBar.bottom, self.view.width, self.view.height - self.searchBar.bottom)];
        _fileManagerView.delegate = self;
        [_fileManagerView refreshingWithAnimate:YES];
        [self.view addSubview:_fileManagerView];
    }
    return _fileManagerView;
}

@end
