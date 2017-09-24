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
}

- (void)dealloc {
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"linkInfo"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"linkInfo"]) {
        [_vc refresh];
    }
}

@end
