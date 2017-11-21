//
//  FileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileViewController.h"
//#import "JHDefaultPageViewController.h"
#import "SMBViewController.h"
#import "HTTPServerViewController.h"
//#import "HelpViewController.h"
#import "FileManagerViewController.h"
//#import "FileManagerNavigationController.h"
//#import "LinkFileManagerNavigationController.h"
#import "LinkFileManagerViewController.h"
#import "QRScanerViewController.h"
//
//#import "JHEdgeButton.h"
//#import "FileManagerSearchView.h"
//#import "JHExpandView.h"
//#import "JHSearchBar.h"
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
//<WMPageControllerDataSource, WMPageControllerDelegate, UISearchBarDelegate, FileManagerSearchViewDelegate>
//@property (strong, nonatomic) JHDefaultPageViewController *pageController;
//@property (strong, nonatomic) NSArray <NSString *>*titleArr;
//@property (strong, nonatomic) UIButton *httpButton;
//@property (strong, nonatomic) UIButton *helpButton;
//@property (strong, nonatomic) UIButton *qrCodeButton;
//@property (strong, nonatomic) JHSearchBar *searchBar;



//@property (strong, nonatomic) FileManagerSearchView *searchView;
@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"文件";
//    [self configRightItem];
    [[CacheManager shareCacheManager] addObserver:self];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    //    [self.treeView reloadData];
    //    [self.dataSources enumerateObjectsUsingBlock:^(JHFileTreeNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //        [self.treeView expandRowForItem:obj expandChildren:YES withRowAnimation:RATreeViewRowAnimationNone];
    //    }];
}

- (void)dealloc {
    [[CacheManager shareCacheManager] removeObserver:self];
}

//#pragma mark - RATreeViewDataSource
//- (NSInteger)treeView:(RATreeView *)treeView numberOfChildrenOfItem:(JHFileTreeNode *)item {
//    if (item == nil) {
//        return self.dataSources.count;
//    }
//
//    if ([item isKindOfClass:[JHCollectionCache class]]) {
//        return 0;
//    }
//
//    if (item.type == JHFileTreeNodeTypeSection && [item.name isEqualToString:@"收藏"]) {
//        return [CacheManager shareCacheManager].collectionList.count;
//    }
//
//    return item.subItems.count;
//}
//
//- (UITableViewCell *)treeView:(RATreeView *)treeView cellForItem:(JHFileTreeNode *)item {
//    if ([item isKindOfClass:[JHCollectionCache class]]) {
//        JHCollectionCache *cache = (JHCollectionCache *)item;
//        JHFileCollectionTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"JHFileCollectionTableViewCell"];
//        cell.titleLabel.text = cache.name;
//        cell.detailLabel.text = JHCollectionCacheTypeStringValue(cache.cacheType);
//        return cell;
//    }
//
//    if (item.type == JHFileTreeNodeTypeSection) {
//        JHFileLargeTitleTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"JHFileLargeTitleTableViewCell"];
//        cell.titleLabel.text = item.name;
//        if ([treeView isCellForItemExpanded:item] == NO) {
//            cell.arrowImgView.transform = CGAffineTransformIdentity;
//        }
//        else {
//            cell.arrowImgView.transform = CGAffineTransformMakeRotation(M_PI_2);
//        }
//
//        return cell;
//    }
//
//    JHFileSectionTableViewCell *cell = [treeView dequeueReusableCellWithIdentifier:@"JHFileSectionTableViewCell"];
//    cell.iconImgView.image = [UIImage imageNamed:item.icon];
//    cell.titleLabel.text = item.name;
//    return cell;
//}
//
//- (id)treeView:(RATreeView *)treeView child:(NSInteger)index ofItem:(JHFileTreeNode *)item {
//    if (item == nil) {
//        return self.dataSources[index];
//    }
//
//    if (item.type == JHFileTreeNodeTypeSection && [item.name isEqualToString:@"收藏"]) {
//        return [CacheManager shareCacheManager].collectionList[index];
//    }
//
//    return item.subItems[index];
//}
//
//#pragma mark - RATreeViewDelegate
//- (CGFloat)treeView:(RATreeView *)treeView heightForRowForItem:(JHFileTreeNode *)item {
//    if ([item isKindOfClass:[JHFileTreeNode class]]) {
//        if (item.type == JHFileTreeNodeTypeSection) {
//            return 50;
//        }
//        return 44;
//    }
//
//    return 50;
//}
//
//- (void)treeView:(RATreeView *)treeView didSelectRowForItem:(JHFileTreeNode *)item {
//    [treeView deselectRowForItem:item animated:YES];
//    if ([item isKindOfClass:[JHCollectionCache class]]) {
//        JHCollectionCache *cache = (JHCollectionCache *)item;
//        NSLog(@"%@", cache.name);
//    }
//    else if(item.type == JHFileTreeNodeTypeLocation) {
//        if ([item.name isEqualToString:@"本机"]) {
//            FileManagerViewController *vc = [[FileManagerViewController alloc] init];
//            vc.hidesBottomBarWhenPushed = YES;
//            vc.file = jh_getANewRootFile();
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        else if ([item.name isEqualToString:@"远程设备"]) {
//            SMBViewController *vc = [[SMBViewController alloc] init];
//            vc.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        else if ([item.name isEqualToString:@"我的电脑"]) {
//            //已经登录
//            if ([CacheManager shareCacheManager].linkInfo) {
//                LinkFileManagerViewController *vc = [[LinkFileManagerViewController alloc] init];
//                vc.file = jh_getANewLinkRootFile();
//                vc.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//            else {
//                QRScanerViewController *vc = [[QRScanerViewController alloc] init];
//                vc.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//        }
//    }
//}
//
//- (UITableViewCellEditingStyle)treeView:(RATreeView *)treeView editingStyleForRowForItem:(id)item {
//    if ([item isKindOfClass:[JHCollectionCache class]]) {
//        return UITableViewCellEditingStyleDelete;
//    }
//    return UITableViewCellEditingStyleNone;
//}
//
//- (void)treeView:(RATreeView *)treeView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowForItem:(id)item {
//    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"是否删除这个收藏？" message:@"操作无法恢复" preferredStyle:UIAlertControllerStyleAlert];
//    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [[CacheManager shareCacheManager] removeCollectionCache:item];
//    }]];
//
//    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
//
//    [self presentViewController:vc animated:YES completion:nil];
//}
//
//- (NSString *)treeView:(RATreeView *)treeView titleForDeleteConfirmationButtonForRowForItem:(id)item {
//    return @"删除";
//}
//
//- (void)treeView:(RATreeView *)treeView willExpandRowForItem:(JHFileTreeNode *)item {
//    if ([item isKindOfClass:[JHFileTreeNode class]]) {
//        JHFileTreeNode *node = item;
//        if (node.type == JHFileTreeNodeTypeSection) {
//            JHFileLargeTitleTableViewCell *cell = (JHFileLargeTitleTableViewCell *)[treeView cellForItem:node];
//            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                cell.arrowImgView.transform = CGAffineTransformMakeRotation(M_PI_2);
//            } completion:nil];
//        }
//    }
//}
//
//- (void)treeView:(RATreeView *)treeView willCollapseRowForItem:(id)item {
//    if ([item isKindOfClass:[JHFileTreeNode class]]) {
//        JHFileTreeNode *node = item;
//        if (node.type == JHFileTreeNodeTypeSection) {
//            JHFileLargeTitleTableViewCell *cell = (JHFileLargeTitleTableViewCell *)[treeView cellForItem:node];
//            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:20 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                cell.arrowImgView.transform = CGAffineTransformIdentity;
//            } completion:nil];
//        }
//    }
//}
//
//- (BOOL)treeView:(RATreeView *)treeView shouldExpandRowForItem:(JHFileTreeNode *)item {
//    return [item isKindOfClass:[JHFileTreeNode class]] && item.type == JHFileTreeNodeTypeSection;
//}
//
//- (BOOL)treeView:(RATreeView *)treeView shouldCollapaseRowForItem:(JHFileTreeNode *)item {
//    return [item isKindOfClass:[JHFileTreeNode class]] && item.type == JHFileTreeNodeTypeSection;
//}

#pragma mark - CacheManagerDelagate
- (void)collectionDidHandleCache:(JHCollectionCache *)cache operation:(CollectionCacheDidChangeType)operation {
    [self.tableView reloadData];
    //    [self.dataSources enumerateObjectsUsingBlock:^(JHFileTreeNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
    //        [self.treeView expandRowForItem:obj expandChildren:YES withRowAnimation:RATreeViewRowAnimationFade];
    //    }];
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

//- (void)configRightItem {
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"file_add_file"] configAction:^(UIButton *aButton) {
//        [aButton addTarget:self action:@selector(touchHttpButton:) forControlEvents:UIControlEventTouchUpInside];
//    }];
//
//    [self.navigationItem addRightItemFixedSpace:item];
//}

//- (void)touchHttpButton:(UIButton *)button {
//    HTTPServerViewController *vc = [[HTTPServerViewController alloc] init];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//}

//{
//    __weak FileManagerViewController *_fileManagerViewController;
//}
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    [self configRightItem];
//    [self configTitleView];
//    self.extendedLayoutIncludesOpaqueBars = YES;
//
//    [self.pageController.view mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
//
//    //监听滚动
//    [self.pageController.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
//}
//
//- (void)dealloc {
//    [self.pageController.scrollView removeObserver:self forKeyPath:@"contentOffset"];
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if ([keyPath isEqualToString:@"contentOffset"]) {
//        CGPoint offset = [change[NSKeyValueChangeNewKey] CGPointValue];
//        float alpha = offset.x / self.view.width;
//
//        if (alpha > 1) {
//            alpha = alpha - 1;
//            self.httpButton.alpha = 0;
//            self.helpButton.alpha = 1 - alpha;
//            self.qrCodeButton.alpha = alpha;
//            self.searchBar.alpha = 0;
//        }
//        else {
//            self.qrCodeButton.alpha = 0;
//            self.httpButton.alpha = 1 - alpha;
//            self.helpButton.alpha = alpha;
//            self.searchBar.alpha = 1 - alpha;
//        }
//    }
//}
//
//#pragma mark - 私有方法
//- (void)configLeftItem {
//
//}
//
//- (void)configRightItem {
//    UIView *holdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
//    [holdView addSubview:self.httpButton];
//    [holdView addSubview:self.helpButton];
//    [holdView addSubview:self.qrCodeButton];
//
//    [self.httpButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
//
//    [self.helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
//
//    [self.qrCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(0);
//    }];
//
//    self.helpButton.alpha = 0;
//    self.qrCodeButton.alpha = 0;
//
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:holdView];
//    self.navigationItem.rightBarButtonItem = item;
//}
//
//- (void)configTitleView {
//    JHExpandView *searchBarHolderView = [[JHExpandView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
//    [searchBarHolderView addSubview:self.searchBar];
//    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.mas_offset(10);
//        make.trailing.mas_offset(-10);
//        make.top.bottom.mas_equalTo(0);
//    }];
//    self.navigationItem.titleView = searchBarHolderView;
//}
//
//#pragma mark - 懒加载
//- (void)touchHttpButton:(UIButton *)button {
//    HTTPServerViewController *vc = [[HTTPServerViewController alloc] init];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (void)touchHelpButton:(UIButton *)button {
//    HelpViewController *vc = [[HelpViewController alloc] init];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (void)touchQRCodeButton:(UIButton *)button {
//    QRScanerViewController *vc = [[QRScanerViewController alloc] init];
//    vc.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//#pragma mark - WMPageControllerDataSource
//- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
//    return self.titleArr.count;
//}
//
//- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
//    if (index == 0) {
//        FileManagerViewController *vc = [[FileManagerViewController alloc] init];
//        vc.file = jh_getANewRootFile();
//        _fileManagerViewController = vc;
//        FileManagerNavigationController *nav = [[FileManagerNavigationController alloc] initWithRootViewController:vc];
//        return nav;
//    }
//    else if (index == 1) {
//        return [[SMBViewController alloc] init];
//    }
//
//    LinkFileManagerViewController *vc = [[LinkFileManagerViewController alloc] init];
//    vc.file = jh_getANewLinkRootFile();
//    LinkFileManagerNavigationController *nav = [[LinkFileManagerNavigationController alloc] initWithRootViewController:vc];
//
//    return nav;
//}
//
//- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
//    return self.titleArr[index];
//}
//
//- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
//    return CGRectMake(0, self.navigationController.navigationBar.bottom, self.view.width, NORMAL_SIZE_FONT.lineHeight + 20);
//}
//
//- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
//    const float menuViewHeight = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:pageController.menuView]);
//    return CGRectMake(0, menuViewHeight, self.view.width, self.view.height - menuViewHeight);
//}
//
//#pragma mark - UISearchBarDelegate
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
//    [self.searchView show];
//    return NO;
//}
//
//#pragma mark - FileManagerSearchViewDelegate
//- (void)searchView:(FileManagerSearchView *)searchView didSelectedFile:(JHFile *)file {
//    [_fileManagerViewController matchFile:file];
//}
//
//#pragma mark - 懒加载
//- (JHDefaultPageViewController *)pageController {
//    if (_pageController == nil) {
//        _pageController = [[JHDefaultPageViewController alloc] init];
//        _pageController.dataSource = self;
//        _pageController.delegate = self;
//        [self addChildViewController:_pageController];
//        [self.view addSubview:_pageController.view];
//    }
//    return _pageController;
//}
//
//- (JHSearchBar *)searchBar {
//    if (_searchBar == nil) {
//        _searchBar = [[JHSearchBar alloc] init];
//        _searchBar.placeholder = @"搜索文件名";
//        _searchBar.delegate = self;
//        _searchBar.backgroundImage = [[UIImage alloc] init];
//        _searchBar.tintColor = [UIColor whiteColor];
//        _searchBar.textField.font = NORMAL_SIZE_FONT;
//    }
//    return _searchBar;
//}
//
//- (UIButton *)httpButton {
//    if (_httpButton == nil) {
//        _httpButton = [[JHEdgeButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        [_httpButton addTarget:self action:@selector(touchHttpButton:) forControlEvents:UIControlEventTouchUpInside];
//        [_httpButton setImage:[UIImage imageNamed:@"file_add_file"] forState:UIControlStateNormal];
//    }
//    return _httpButton;
//}
//
//- (UIButton *)helpButton {
//    if (_helpButton == nil) {
//        _helpButton = [[JHEdgeButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        [_helpButton addTarget:self action:@selector(touchHelpButton:) forControlEvents:UIControlEventTouchUpInside];
//        [_helpButton setImage:[UIImage imageNamed:@"file_help"] forState:UIControlStateNormal];
//    }
//    return _helpButton;
//}
//
//- (UIButton *)qrCodeButton {
//    if (_qrCodeButton == nil) {
//        _qrCodeButton = [[JHEdgeButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
//        [_qrCodeButton addTarget:self action:@selector(touchQRCodeButton:) forControlEvents:UIControlEventTouchUpInside];
//        [_qrCodeButton setImage:[UIImage imageNamed:@"file_qr_code"] forState:UIControlStateNormal];
//    }
//    return _qrCodeButton;
//}
//
//- (FileManagerSearchView *)searchView {
//    if (_searchView == nil) {
//        _searchView = [[FileManagerSearchView alloc] init];
//        _searchView.delegete = self;
//    }
//    return _searchView;
//}
//
//- (NSArray<NSString *> *)titleArr {
//    if (_titleArr == nil) {
//        _titleArr = @[@"本机文件", @"远程设备", @"电脑端"];
//    }
//    return _titleArr;
//}

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

