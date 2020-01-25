//
//  DDPMineViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMineViewController.h"
#import "DDPSettingViewController.h"
#import "DDPAboutUsViewController.h"
#import "DDPDownloadViewController.h"
#import "DDPAttentionListViewController.h"
#import "DDPLoginViewController.h"
#import "DDPControlVideoViewController.h"

#import "DDPSettingTitleTableViewCell.h"
#import "DDPSettingDownloadTableViewCell.h"
#import "UIView+Tools.h"
#import "DDPEdgeButton.h"
#import "DDPDownloadManager.h"

#import "DDPMineHeadView.h"
#import "DDPTransparentNavigationBar.h"

#if DDPAPPTYPEISMAC
//#import <DDPShare/DDPMessageManager.h>
#import <DDPShare/DDPShare.h>
#else
#import "LogHelper.h"
#import <SSZipArchive/SSZipArchive.h>
#endif

#define TITLE_KEY @"titleLabel.text"

#define TITLE_VIEW_RATE 0.4

@interface DDPMineViewController ()<UITableViewDelegate, UITableViewDataSource,
#if !DDPAPPTYPE
DDPDownloadManagerObserver,
#endif
UIScrollViewDelegate, DDPCacheManagerDelagate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray <NSDictionary *>*dataSourceArr;

@property (strong, nonatomic) DDPMineHeadView *headView;


@property (strong, nonatomic) UIVisualEffectView *blurView;
@end

@implementation DDPMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self.headView.height);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
#if !DDPAPPTYPE
    [[DDPDownloadManager shareDownloadManager] addObserver:self];
#endif
    
    [[DDPToolsManager shareToolsManager] addObserver:self forKeyPath:DDP_KEYPATH([DDPToolsManager shareToolsManager], SMBSession) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    [[DDPCacheManager shareCacheManager] addObserver:self];
    
    [self reloadUserInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNavigationBarWithColor: UIColor.clearColor];
}

- (void)dealloc {
#if !DDPAPPTYPE
    [[DDPDownloadManager shareDownloadManager] removeObserver:self];
#endif
//    [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:DDP_KEYPATH([DDPCacheManager shareCacheManager], currentUser)];
    [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:DDP_KEYPATH([DDPToolsManager shareToolsManager], SMBSession)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:DDP_KEYPATH([DDPToolsManager shareToolsManager], SMBSession)]) {
        self.dataSourceArr = nil;
        [self.tableView reloadData];
    }
}

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment_setting"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem) forControlEvents:UIControlEventTouchUpInside];
    }];
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem {
    DDPSettingViewController *vc = [[DDPSettingViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *dic = self.dataSourceArr[indexPath.row];
    
    DDPOtherSettingTitleSubtitleTableViewCell *cell = nil;
    
    if ([dic[TITLE_KEY] isEqualToString:@"下载任务"]) {
#if !DDPAPPTYPE
        DDPSettingDownloadTableViewCell *aCell = [tableView dequeueReusableCellWithIdentifier:@"DDPSettingDownloadTableViewCell" forIndexPath:indexPath];
        aCell.downLoadCount = [DDPDownloadManager shareDownloadManager].tasks.count;
        cell = aCell;
#endif
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DDPSettingTitleTableViewCell" forIndexPath:indexPath];
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.titleLabel.textColor = [UIColor blackColor];
    [self.dataSourceArr[indexPath.row] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [cell setValue:obj forKeyPath:key];
    }];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.dataSourceArr[indexPath.row];
    
    if ([dic[TITLE_KEY] isEqualToString:@"我的关注"]) {
        DDPAttentionListViewController *vc = [[DDPAttentionListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
#if !DDPAPPTYPE
    else if ([dic[TITLE_KEY] isEqualToString:@"下载任务"]) {
        DDPDownloadViewController *vc = [[DDPDownloadViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([dic[TITLE_KEY] isEqualToString:@"遥控器"]) {
        DDPControlVideoViewController *vc = [[DDPControlVideoViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([dic[TITLE_KEY] isEqual:@"分享日志给开发者"]) {
        let path = [LogHelper logPath];
        
        NSString *zipPath = [path stringByAppendingPathComponent:@"log.zip"];
        if ([SSZipArchive createZipFileAtPath:zipPath withContentsOfDirectory:path]) {
            NSURL *url = [NSURL fileURLWithPath:zipPath];
            if (url) {
                UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
                [self presentViewController:vc animated:YES completion:nil];
            }
        }
    }
#endif
    else {
        DDPAboutUsViewController *vc = [[DDPAboutUsViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44 + ddp_isPad() * 10;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float y = -scrollView.contentOffset.y / self.view.height * 4 + 1;
    if (y <= 1) y = 1;
    
    self.blurView.transform = CGAffineTransformMakeScale(y, y);
}

#if !DDPAPPTYPE
#pragma mark - DDPDownloadManagerObserver
- (void)tasksDidChange:(NSArray <id<DDPDownloadTaskProtocol>>*)tasks
                  type:(DDPDownloadTasksChangeType)type
                 error:(NSError *)error {
    [self.tableView reloadData];
}
#endif

#pragma mark - DDPCacheManagerDelagate
- (void)userLoginStatusDidChange:(DDPUser *)user {
    [self reloadUserInfo];
}

- (void)linkInfoDidChange:(DDPLinkInfo *)linkInfo {
    self.dataSourceArr = nil;
    [self.tableView reloadData];
}

#pragma mark - 私有方法
- (void)configLeftItem {
    
}

- (void)reloadUserInfo {
    let user = [DDPCacheManager shareCacheManager].currentUser;
    self.headView.model = user;
    
    [self.blurView.layer ddp_setImageWithURL:user.isLogin ? user.iconImgURL : nil placeholder:[UIImage imageNamed:@"comment_icon"]];
    
    self.dataSourceArr = nil;
    [self.tableView reloadData];
}

- (Class)ddp_navigationBarClass {
    return [DDPTransparentNavigationBar class];
}

#pragma mark - 懒加载
- (UIVisualEffectView *)blurView {
    if (_blurView == nil) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _blurView.layer.contentMode = UIViewContentModeScaleAspectFill;
        _blurView.layer.masksToBounds = YES;
        [self.view addSubview:_blurView];
    }
    return _blurView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableHeaderView = self.headView;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        [_tableView registerClass:[DDPSettingTitleTableViewCell class] forCellReuseIdentifier:@"DDPSettingTitleTableViewCell"];
#if !DDPAPPTYPE
        [_tableView registerClass:[DDPSettingDownloadTableViewCell class] forCellReuseIdentifier:@"DDPSettingDownloadTableViewCell"];
#endif
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (DDPMineHeadView *)headView {
    if (_headView == nil) {
        _headView = [DDPMineHeadView fromXib];
        _headView.frame = CGRectMake(0, 0, self.view.width, self.view.height * TITLE_VIEW_RATE + CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame));
    }
    return _headView;
}

- (NSArray<NSDictionary *> *)dataSourceArr {
    if (_dataSourceArr == nil) {
        NSMutableArray *arr = [NSMutableArray array];
        
        
        if (ddp_appType == DDPAppTypeDefault) {
            if ([DDPCacheManager shareCacheManager].currentUser.isLogin) {
                [arr addObject:@{TITLE_KEY: @"我的关注"}];
            }
            
            if ([DDPCacheManager shareCacheManager].linkInfo != nil || [DDPToolsManager shareToolsManager].SMBSession != nil) {
                [arr addObject:@{TITLE_KEY: @"下载任务"}];
            }
            
            [arr addObject:@{TITLE_KEY: @"遥控器"}];
            
            [arr addObject:@{TITLE_KEY: @"分享日志给开发者"}];
        } else if (ddp_appType == DDPAppTypeToMac) {
            if ([DDPCacheManager shareCacheManager].currentUser.isLogin) {
                [arr addObject:@{TITLE_KEY: @"我的关注"}];
            }
        }
        
        [arr addObjectsFromArray:@[
                                   @{TITLE_KEY: [NSString stringWithFormat:@"关于%@", [UIApplication sharedApplication].appDisplayName]}
                                   ]];
        
        
        _dataSourceArr = arr;
    }
    return _dataSourceArr;
}

@end

