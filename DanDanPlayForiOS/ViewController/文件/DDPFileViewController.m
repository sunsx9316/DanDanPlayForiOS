//
//  DDPFileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileViewController.h"
#import "DDPHTTPServerViewController.h"
#import "DDPFileManagerViewController.h"
#import "DDPLinkFileManagerViewController.h"
#import "DDPQRScannerViewController.h"

#if !DDPAPPTYPEISMAC
#import "DDPSMBViewController.h"
#endif

#import "DDPBaseTreeView.h"
#import "DDPFileLargeTitleTableViewCell.h"
#import "DDPFileSectionTableViewCell.h"
#import "DDPFileCollectionTableViewCell.h"

#import "UITableViewCell+Tools.h"
#import "DDPFileTreeNode.h"
#import "DDPCollectionCache.h"

@interface DDPFileViewController ()<UITableViewDelegate, UITableViewDataSource, DDPCacheManagerDelagate>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) NSArray <DDPFileTreeNode *>*dataSources;
@end

@implementation DDPFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"文件";
    [[DDPCacheManager shareCacheManager] addObserver:self];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)dealloc {
    [[DDPCacheManager shareCacheManager] removeObserver:self];
}

#pragma mark - DDPCacheManagerDelagate
- (void)collectionDidHandleCache:(DDPCollectionCache *)cache operation:(DDPCollectionCacheDidChangeType)operation {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    DDPFileTreeNode *node = self.dataSources[section];
    
    if (section == 0) {
        return self.dataSources.firstObject.subItems.count * node.isExpand;
    }
    return [DDPCacheManager shareCacheManager].collectors.count * node.isExpand;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        DDPFileTreeNode *node = self.dataSources.firstObject.subItems[indexPath.row];
        DDPFileSectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileSectionTableViewCell" forIndexPath:indexPath];
        cell.iconImgView.image = node.img;
        cell.titleLabel.text = node.name;
        return cell;
    }
    
    DDPCollectionCache *cache = [DDPCacheManager shareCacheManager].collectors[indexPath.row];
    DDPFileCollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPFileCollectionTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = cache.name;
    cell.detailLabel.text = DDPCollectionCacheTypeStringValue(cache.cacheType);
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    DDPFileTreeNode *node = self.dataSources[section];
    DDPFileLargeTitleTableViewCell *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDPFileLargeTitleTableViewCell"];
    view.titleLabel.text = node.name;
    if (node.isExpand) {
        view.arrowImgView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else {
        view.arrowImgView.transform = CGAffineTransformIdentity;
    }
    
    @weakify(self)
    view.touchTitleCallBack = ^(DDPFileLargeTitleTableViewCell *cell) {
        @strongify(self)
        if (!self) return;
        
        node.expand = !node.isExpand;
        
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            if (node.isExpand) {
                cell.arrowImgView.transform = CGAffineTransformMakeRotation(M_PI_2);
            }
            else {
                cell.arrowImgView.transform = CGAffineTransformIdentity;
            }
        } completion:nil];
        
        [self.tableView reloadSection:section withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    return view;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44 + ddp_isPad() * 20;
    }
    
//    return 50 + ddp_isPad() * 20;
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50 + ddp_isPad() * 20;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否删除这个收藏？" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                DDPCollectionCache *cache = [DDPCacheManager shareCacheManager].collectors[indexPath.row];
                [[DDPCacheManager shareCacheManager] removeCollector:cache];
                [self.tableView reloadData];
            }]];
            
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:vc animated:YES completion:nil];
        }];
        return @[action];
    }
    return @[];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        DDPFileTreeNode *item = self.dataSources[indexPath.section].subItems[indexPath.row];
        
        if ([item.name isEqualToString:@"本机视频"]) {
            DDPFileManagerViewController *vc = [[DDPFileManagerViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.file = ddp_getANewRootFile();
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if ([item.name isEqualToString:@"局域网设备"]) {
#if !DDPAPPTYPEISMAC
            DDPSMBViewController *vc = [[DDPSMBViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
#endif
        }
        else if ([item.name isEqualToString:@"我的电脑"]) {
#if !DDPAPPTYPE
            //已经登录
            if ([DDPCacheManager shareCacheManager].linkInfo) {
                DDPLinkFileManagerViewController *vc = [[DDPLinkFileManagerViewController alloc] init];
                vc.file = ddp_getANewLinkRootFile();
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
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
#endif
        }
    }
    else {
        DDPCollectionCache *cache = [DDPCacheManager shareCacheManager].collectors[indexPath.row];
        if (cache.cacheType == DDPCollectionCacheTypeLocal) {
            NSString *path = [cache.filePath stringByURLEncode];
            if (path.length == 0) {
                [self.view showWithText:@"文件夹被移动或删除!"];
                return;
            }
            
            [[DDPToolsManager shareToolsManager] startDiscovererAllFileWithType:PickerFileTypeVideo completion:^(DDPFile *aFile) {
                
                __block DDPFile *tempFile = nil;
                [aFile.subFiles enumerateObjectsUsingBlock:^(__kindof DDPFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *tempFilePath = obj.fileURL.absoluteString;
                    if ([tempFilePath hasSuffix:path] || [tempFilePath hasSuffix:[path stringByAppendingString:@"/"]]) {
                        tempFile = obj;
                        *stop = YES;
                    }
                }];
                
                if (tempFile == nil) {
                    [self.view showWithText:@"文件夹被移动或删除!"];
                    return;
                }
                
                DDPFileManagerViewController *vc = [[DDPFileManagerViewController alloc] init];
                vc.file = tempFile;
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }
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
        _tableView.estimatedRowHeight = 60;
        [_tableView registerClass:[DDPFileSectionTableViewCell class] forCellReuseIdentifier:@"DDPFileSectionTableViewCell"];
        [_tableView registerClass:[DDPFileLargeTitleTableViewCell class] forHeaderFooterViewReuseIdentifier:@"DDPFileLargeTitleTableViewCell"];
        [_tableView registerClass:[DDPFileCollectionTableViewCell class] forCellReuseIdentifier:@"DDPFileCollectionTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<DDPFileTreeNode *> *)dataSources {
    if (_dataSources == nil) {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:({
            DDPFileTreeNode *node = [[DDPFileTreeNode alloc] init];
            node.type = DDPFileTreeNodeTypeSection;
            node.name = @"位置";
            node.expand = YES;
            
            [node.subItems addObject:({
                DDPFileTreeNode *node = [[DDPFileTreeNode alloc] init];
                node.name = @"本机视频";
                node.type = DDPFileTreeNodeTypeLocation;
                node.img = [[UIImage imageNamed:@"file_phone"] yy_imageByTintColor:[UIColor darkGrayColor]];
                node;
            })];
            
            if (ddp_appType == DDPAppTypeDefault) {
                [node.subItems addObject:({
                    DDPFileTreeNode *node = [[DDPFileTreeNode alloc] init];
                    node.name = @"局域网设备";
                    node.type = DDPFileTreeNodeTypeLocation;
                    node.img = [[UIImage imageNamed:@"file_net_equipment"] yy_imageByTintColor:[UIColor darkGrayColor]];
                    node;
                })];
                
                [node.subItems addObject:({
                    DDPFileTreeNode *node = [[DDPFileTreeNode alloc] init];
                    node.name = @"我的电脑";
                    node.type = DDPFileTreeNodeTypeLocation;
                    node.img = [[UIImage imageNamed:@"file_computer"] yy_imageByTintColor:[UIColor darkGrayColor]];
                    node;
                })];
            }
            
            
            node;
        })];
        
        [arr addObject:({
            DDPFileTreeNode *node = [[DDPFileTreeNode alloc] init];
            node.type = DDPFileTreeNodeTypeSection;
            node.name = @"收藏";
            node.expand = YES;
            node;
        })];
        
        _dataSources = arr;
    }
    return _dataSources;
}

@end

