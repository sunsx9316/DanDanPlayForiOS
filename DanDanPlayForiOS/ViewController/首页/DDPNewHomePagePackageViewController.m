//
//  DDPNewHomePagePackageViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewHomePagePackageViewController.h"
#import "DDPNewHomePageViewController.h"
#import "DDPHomePageSearchPackageViewController.h"

@interface DDPNewHomePagePackageViewController ()
@property (strong, nonatomic) DDPNewHomePageViewController *homePageViewController;
@end

@implementation DDPNewHomePagePackageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"首页";
    [self addChildViewController:self.homePageViewController];
    [self.view addSubview:self.homePageViewController.view];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.homePageViewController.view.frame = self.view.bounds;
}

- (void)configLeftItem {
    
}

- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_search"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem) forControlEvents:UIControlEventTouchUpInside];
    }];
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem {
    let vc = [[DDPHomePageSearchPackageViewController alloc] init];
    vc.hidesBottomBarWhenPushed = true;
    [self.navigationController pushViewController:vc animated:true];
}

#pragma mark - 懒加载
- (DDPNewHomePageViewController *)homePageViewController {
    if (_homePageViewController == nil) {
        _homePageViewController = [[DDPNewHomePageViewController alloc] init];
    }
    return _homePageViewController;
}

@end
