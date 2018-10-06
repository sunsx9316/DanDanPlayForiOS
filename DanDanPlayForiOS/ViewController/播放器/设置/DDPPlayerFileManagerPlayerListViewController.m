//
//  DDPPlayerFileManagerPlayerListViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPPlayerFileManagerPlayerListViewController.h"
#import "DDPFileManagerPlayerListView.h"
#import "DDPBaseTableView.h"

@interface DDPPlayerFileManagerPlayerListViewController ()<DDPFileManagerPlayerListViewDelegete>
@property (strong, nonatomic) DDPFileManagerPlayerListView *listView;
@end

@implementation DDPPlayerFileManagerPlayerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.listView];
    [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - DDPFileManagerPlayerListViewDelegete
- (void)managerView:(DDPFileManagerPlayerListView *)managerView didselectedModel:(DDPFile *)file {
    if (self.didSelectedVideoModelCallBack) {
        self.didSelectedVideoModelCallBack(file.videoModel);
    }
}

- (DDPFileManagerPlayerListView *)listView {
    if (_listView == nil) {
        _listView = [[DDPFileManagerPlayerListView alloc] init];
        _listView.delegate = self;
        _listView.currentFile = [DDPCacheManager shareCacheManager].currentPlayVideoModel.file.parentFile;
    }
    return _listView;
}

@end
