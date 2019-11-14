//
//  DDPOfficialSearchViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPOfficialSearchViewController.h"

#if !DDPAPPTYPEISMAC
#import "DDPPlayerViewController.h"
#import "DDPPlayNavigationController.h"
#endif

#import "DDPSearchAnimeTitleTableViewCell.h"
#import "DDPSearchEpisodeTableViewCell.h"
#import "DDPMatchTitleTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>

#import "DDPBaseTreeView.h"

@interface DDPOfficialSearchViewController ()<RATreeViewDelegate, RATreeViewDataSource>
@property (strong, nonatomic) DDPBaseTreeView *treeView;
@property (strong, nonatomic) NSMutableDictionary <NSString *, NSMutableArray <DDPSearch *>*>*classifyDic;
@end

@implementation DDPOfficialSearchViewController
{
    NSArray <NSString *>*_resortKeys;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.treeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.treeView.ddp_tableView.mj_header beginRefreshing];
}

- (void)setKeyword:(NSString *)keyword {
    _keyword = keyword;
    if (self.isViewLoaded) {
        [self.treeView.ddp_tableView.mj_header beginRefreshing];
    }
}

#pragma mark - RATreeViewDelegate
- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(id)item {
    if ([item isKindOfClass:[NSString class]] || [item isKindOfClass:[DDPSearch class]]) {
        return 44;
    }
    
    DDPEpisode *episode = item;
    return [treeView.ddp_tableView fd_heightForCellWithIdentifier:@"DDPSearchEpisodeTableViewCell" cacheByKey:item configuration:^(DDPSearchEpisodeTableViewCell *cell) {
        cell.titleLabel.text = episode.name;
    }];
}

- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(id)item {
    if ([item isKindOfClass:[NSString class]] || [item isKindOfClass:[DDPSearch class]]) {
        DDPMatchTitleTableViewCell *cell = (DDPMatchTitleTableViewCell *)[treeView cellForItem:item];
        [cell expandArrow:YES animate:YES];
    }
}

- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
    if ([item isKindOfClass:[NSString class]] || [item isKindOfClass:[DDPSearch class]]) {
        DDPMatchTitleTableViewCell *cell = (DDPMatchTitleTableViewCell *)[treeView cellForItem:item];
        [cell expandArrow:NO animate:YES];
    }
}

- (UITableViewCellEditingStyle)treeView:(RATreeView *)treeView editingStyleForRowForItem:(DDPFile *)item {
    return UITableViewCellEditingStyleNone;
}

- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(DDPEpisode *)item {
    [treeView deselectRowForItem:item animated:YES];
    if ([item isKindOfClass:[DDPEpisode class]]) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
        
        [DDPCommentNetManagerOperation danmakusWithEpisodeId:item.identity progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = ddp_danmakusProgressToString(progress);
        } completionHandler:^(DDPDanmakuCollection *responseObject, NSError *error) {
            [aHUD hideAnimated:YES];
            self.model.danmakus = responseObject;
            self.model.matchName = item.name;
            self.model.identity = item.identity;
            
#if !DDPAPPTYPEISMAC
            __block DDPPlayerViewController *vc = nil;
            [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[DDPPlayerViewController class]]) {
                    vc = obj;
                    *stop = YES;
                }
            }];
            
            //更改匹配信息
            [DDPMatchNetManagerOperation matchEditMatchVideoModel:self.model user:[DDPCacheManager shareCacheManager].currentUser completionHandler:^(NSError *error) {
                LOG_ERROR(DDPLogModuleFile, @"匹配失败 %@", error);
            }];
            
            if (vc) {
                vc.model = self.model;
                [self.navigationController popToViewController:vc animated:YES];
            }
            else {
                DDPPlayNavigationController *nav = [[DDPPlayNavigationController alloc] initWithModel:self.model];
                [self presentViewController:nav animated:YES completion:nil];
            }
#endif
        }];
    }
}

#pragma mark - RATreeViewDataSource
- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(nullable id)item {
    if (item == nil) {
        return _resortKeys.count;
    }
    
    if ([item isKindOfClass:[NSString class]]) {
        NSArray *arr = self.classifyDic[item];
        return arr.count;
    }
    
    if ([item isKindOfClass:[DDPSearch class]]) {
        return [item episodes].count;
    }
    
    return 0;
}

- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(nullable id)item {
    if ([item isKindOfClass:[NSString class]]) {
        DDPMatchTitleTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"DDPMatchTitleTableViewCell"];
        cell.titleLabel.text = item;
        [cell expandArrow:[treeView isCellForItemExpanded:item] animate:NO];
        return cell;
    }
    
    if ([item isKindOfClass:[DDPSearch class]]) {
        DDPSearchAnimeTitleTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"DDPSearchAnimeTitleTableViewCell"];
        cell.titleLabel.text = [item name];
        [cell expandArrow:[treeView isCellForItemExpanded:item] animate:NO];
        return cell;
    }
    
    DDPEpisode *episode = item;
    DDPSearchEpisodeTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"DDPSearchEpisodeTableViewCell"];
    cell.titleLabel.text = episode.name;
    return cell;
}

- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(nullable id)item {
    if (item == nil) {
        return _resortKeys[index];
    }
    
    if ([item isKindOfClass:[NSString class]]) {
        return self.classifyDic[item][index];
    }
    
    return [item episodes][index];
    
}

#pragma mark - 私有方法
- (void)classifyWithColletion:(DDPSearchCollection *)collection {
    [self.classifyDic removeAllObjects];
    
    [collection.collection enumerateObjectsUsingBlock:^(DDPSearch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.classifyDic[obj.typeDescription] == nil) {
            self.classifyDic[obj.typeDescription] = [NSMutableArray array];
        }
        
        [self.classifyDic[obj.typeDescription] addObject:obj];
    }];
    
    _resortKeys = [[self.classifyDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString * _Nonnull obj1, NSString * _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}



#pragma mark - 懒加载
- (DDPBaseTreeView *)treeView {
    if (_treeView == nil) {
        _treeView = [[DDPBaseTreeView alloc] initWithFrame:CGRectZero style:RATreeViewStylePlain];
        _treeView.delegate = self;
        _treeView.dataSource = self;
        _treeView.separatorStyle = RATreeViewCellSeparatorStyleNone;
        _treeView.rowsExpandingAnimation = RATreeViewRowAnimationTop;
        _treeView.rowsCollapsingAnimation = RATreeViewRowAnimationTop;
        [_treeView registerClass:[DDPSearchAnimeTitleTableViewCell class] forCellReuseIdentifier:@"DDPSearchAnimeTitleTableViewCell"];
        [_treeView registerClass:[DDPSearchEpisodeTableViewCell class] forCellReuseIdentifier:@"DDPSearchEpisodeTableViewCell"];
        [_treeView registerClass:[DDPMatchTitleTableViewCell class] forCellReuseIdentifier:@"DDPMatchTitleTableViewCell"];
        @weakify(self)
        _treeView.ddp_tableView.mj_header = [MJRefreshNormalHeader ddp_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            NSArray *keywords = [self.keyword componentsSeparatedByString:@" "];
            
            
            [DDPSearchNetManagerOperation searchOfficialWithKeyword:keywords.firstObject episode:[keywords.lastObject integerValue] completionHandler:^(DDPSearchCollection *responseObject, NSError *error) {
                if (error) {
                    [self.view showWithError:error];
                }
                else {
                    [self classifyWithColletion:responseObject];
                    [self.treeView reloadData];
                    [self.treeView expandRowForItem:self->_resortKeys.firstObject expandChildren:true withRowAnimation:RATreeViewRowAnimationNone];
                }
                
                [self.treeView endRefreshing];
            }];
        }];
        [self.view addSubview:_treeView];
    }
    return _treeView;
}

- (NSMutableDictionary<NSString *,NSMutableArray<DDPSearch *> *> *)classifyDic {
    if (_classifyDic == nil) {
        _classifyDic = [NSMutableDictionary dictionary];
    }
    return _classifyDic;
}

@end
