//
//  LinkFileManagerNavigationController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LinkFileManagerNavigationController.h"
#import "FileManagerNavigationBar.h"
#import "LinkFileManagerViewController.h"

@interface LinkFileManagerNavigationController ()

@end

@implementation LinkFileManagerNavigationController
{
    CGRect _rect;
    LinkFileManagerViewController *_vc;
}

- (instancetype)initWithRootViewController:(LinkFileManagerViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[FileManagerNavigationBar class] toolbarClass:nil]) {
        [self setViewControllers:@[rootViewController]];
        _vc = rootViewController;
        [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"linkInfo" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
//    CGFloat value = NORMAL_SIZE_FONT.lineHeight + 20;
//    self.preferredContentSize = CGSizeMake(self.view.width, kScreenHeight );
//    _rect = CGRectMake(0, 0, self.view.width, kScreenHeight - value - CGRectGetMaxY(self.navigationController.navigationBar.frame));
}

- (void)dealloc {
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"linkInfo"];
}

//- (void)loadView {
//    [super loadView];
//    self.view.frame = _rect;
//}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    self.view.frame = (CGRect){0,0,kScreenSize};
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"linkInfo"]) {
        [_vc refresh];
    }
}

@end
