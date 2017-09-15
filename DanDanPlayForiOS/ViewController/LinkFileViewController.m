//
//  LinkFileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LinkFileViewController.h"
#import "LinkFileManagerViewController.h"
//#import "QRScanerViewController.h"
//
//#import "BaseTableView.h"
//#import "LinkFileTableViewCell.h"

@interface LinkFileViewController ()
//<UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
//@property (strong, nonatomic) BaseTableView *tableView;
//@property (strong, nonatomic) JHLibraryCollection *model;
@property (strong, nonatomic) LinkFileManagerViewController *linkFileManagerViewController;
@end

@implementation LinkFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.linkFileManagerViewController];
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    
    [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"linkInfo" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"linkInfo"]) {
        [self.linkFileManagerViewController refresh];
    }
}

- (void)dealloc {
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"linkInfo"];
}

#pragma mark - 懒加载
- (LinkFileManagerViewController *)linkFileManagerViewController {
    if (_linkFileManagerViewController == nil) {
        _linkFileManagerViewController = [[LinkFileManagerViewController alloc] init];
        _linkFileManagerViewController.file = jh_getANewLinkRootFile();
    }
    return _linkFileManagerViewController;
}

@end
