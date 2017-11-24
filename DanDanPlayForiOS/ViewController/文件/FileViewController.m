//
//  FileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileViewController.h"
#import "SMBViewController.h"
#import "HTTPServerViewController.h"
#import "FileManagerViewController.h"
#import "LinkFileManagerViewController.h"
#import "QRScanerViewController.h"

#import "JHBaseTreeView.h"
#import "JHFileLargeTitleTableViewCell.h"
#import "JHFileSectionTableViewCell.h"
#import "JHFileCollectionTableViewCell.h"

#import "UITableViewCell+Tools.h"
#import "JHFileTreeNode.h"
#import "JHCollectionCache.h"

@interface FileViewController ()<UITableViewDelegate, UITableViewDataSource, CacheManagerDelagate>
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) NSArray <JHFileTreeNode *>*dataSources;
@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"文件";
    [[CacheManager shareCacheManager] addObserver:self];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)dealloc {
    [[CacheManager shareCacheManager] removeObserver:self];
}

#pragma mark - CacheManagerDelagate
- (void)collectionDidHandleCache:(JHCollectionCache *)cache operation:(CollectionCacheDidChangeType)operation {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    JHFileTreeNode *node = self.dataSources[section];
    
    if (section == 0) {
        return self.dataSources.firstObject.subItems.count * node.isExpand;
    }
    return [CacheManager shareCacheManager].collectionList.count * node.isExpand;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        JHFileTreeNode *node = self.dataSources.firstObject.subItems[indexPath.row];
        JHFileSectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JHFileSectionTableViewCell" forIndexPath:indexPath];
        cell.iconImgView.image = node.img;
        cell.titleLabel.text = node.name;
        return cell;
    }
    
    JHCollectionCache *cache = [CacheManager shareCacheManager].collectionList[indexPath.row];
    JHFileCollectionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JHFileCollectionTableViewCell" forIndexPath:indexPath];
    cell.titleLabel.text = cache.name;
    cell.detailLabel.text = JHCollectionCacheTypeStringValue(cache.cacheType);
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    JHFileTreeNode *node = self.dataSources[section];
    JHFileLargeTitleTableViewCell *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"JHFileLargeTitleTableViewCell"];
    view.titleLabel.text = node.name;
    if (node.isExpand) {
        view.arrowImgView.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else {
        view.arrowImgView.transform = CGAffineTransformIdentity;
    }
    
    @weakify(self)
    view.touchTitleCallBack = ^(JHFileLargeTitleTableViewCell *cell) {
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
        return 44 + jh_isPad() * 20;
    }
    
    return 50 + jh_isPad() * 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50 + jh_isPad() * 20;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"是否删除这个收藏？" message:@"操作无法恢复" preferredStyle:UIAlertControllerStyleAlert];
            [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                JHCollectionCache *cache = [CacheManager shareCacheManager].collectionList[indexPath.row];
                [[CacheManager shareCacheManager] removeCollectionCache:cache];
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
        JHFileTreeNode *item = self.dataSources[indexPath.section].subItems[indexPath.row];
        
        if ([item.name isEqualToString:@"本机"]) {
            FileManagerViewController *vc = [[FileManagerViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.file = jh_getANewRootFile();
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if ([item.name isEqualToString:@"远程设备"]) {
            SMBViewController *vc = [[SMBViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if ([item.name isEqualToString:@"我的电脑"]) {
            //已经登录
            if ([CacheManager shareCacheManager].linkInfo) {
                LinkFileManagerViewController *vc = [[LinkFileManagerViewController alloc] init];
                vc.file = jh_getANewLinkRootFile();
                vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else {
                QRScanerViewController *vc = [[QRScanerViewController alloc] init];
                vc.hidesBottomBarWhenPushed = YES;
                @weakify(self)
                vc.linkSuccessCallBack = ^(JHLinkInfo *info) {
                    @strongify(self)
                    if (!self) return;
                    
                    NSMutableArray *arr = [self.navigationController.viewControllers mutableCopy];
                    [arr removeLastObject];
                    
                    
                    //连接成功直接跳转到列表
                    LinkFileManagerViewController *avc = [[LinkFileManagerViewController alloc] init];
                    avc.file = jh_getANewLinkRootFile();
                    avc.hidesBottomBarWhenPushed = YES;
                    [arr addObject:avc];
                    [self.navigationController setViewControllers:arr animated:YES];
                };
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
    else {
        JHCollectionCache *cache = [CacheManager shareCacheManager].collectionList[indexPath.row];
        if (cache.cacheType == JHCollectionCacheTypeLocal) {
            NSString *path = cache.filePath;
            if (path.length == 0) return;
            
            NSURL *aURL = [NSURL fileURLWithPath:[[UIApplication sharedApplication].documentsPath stringByAppendingPathComponent:path]];
            
            JHFile *file = [[JHFile alloc] initWithFileURL:aURL type:JHFileTypeFolder];

            [[ToolsManager shareToolsManager] startDiscovererVideoWithFile:file type:PickerFileTypeAll completion:^(JHFile *aFile) {
                if (aFile == nil) {
                    [MBProgressHUD showWithText:@"文件夹被移动或删除！"];
                    return;
                }
                
                FileManagerViewController *vc = [[FileManagerViewController alloc] init];
                vc.file = aFile;
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
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[JHFileSectionTableViewCell class] forCellReuseIdentifier:@"JHFileSectionTableViewCell"];
        [_tableView registerClass:[JHFileLargeTitleTableViewCell class] forHeaderFooterViewReuseIdentifier:@"JHFileLargeTitleTableViewCell"];
        [_tableView registerClass:[JHFileCollectionTableViewCell class] forCellReuseIdentifier:@"JHFileCollectionTableViewCell"];
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<JHFileTreeNode *> *)dataSources {
    if (_dataSources == nil) {
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:({
            JHFileTreeNode *node = [[JHFileTreeNode alloc] init];
            node.type = JHFileTreeNodeTypeSection;
            node.name = @"位置";
            node.expand = YES;
            
            [node.subItems addObject:({
                JHFileTreeNode *node = [[JHFileTreeNode alloc] init];
                node.name = @"本机";
                node.type = JHFileTreeNodeTypeLocation;
                node.img = [[UIImage imageNamed:@"file_phone"] yy_imageByTintColor:[UIColor darkGrayColor]];
                node;
            })];
            
            [node.subItems addObject:({
                JHFileTreeNode *node = [[JHFileTreeNode alloc] init];
                node.name = @"远程设备";
                node.type = JHFileTreeNodeTypeLocation;
                node.img = [[UIImage imageNamed:@"file_net_equipment"] yy_imageByTintColor:[UIColor darkGrayColor]];
                node;
            })];
            
            [node.subItems addObject:({
                JHFileTreeNode *node = [[JHFileTreeNode alloc] init];
                node.name = @"我的电脑";
                node.type = JHFileTreeNodeTypeLocation;
                node.img = [[UIImage imageNamed:@"file_computer"] yy_imageByTintColor:[UIColor darkGrayColor]];
                node;
            })];
            
            node;
        })];
        
        [arr addObject:({
            JHFileTreeNode *node = [[JHFileTreeNode alloc] init];
            node.type = JHFileTreeNodeTypeSection;
            node.name = @"收藏";
            node.expand = YES;
            node;
        })];
        
        _dataSources = arr;
    }
    return _dataSources;
}

@end

