//
//  FileManagerNavigationController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerNavigationController.h"
#import "FileManagerNavigationBar.h"

@interface FileManagerNavigationController ()

@end

@implementation FileManagerNavigationController
{
    CGRect _rect;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[FileManagerNavigationBar class] toolbarClass:nil]) {
        [self setViewControllers:@[rootViewController]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat value = NORMAL_SIZE_FONT.lineHeight + 20;
    _rect = CGRectMake(0, 0, self.view.width, kScreenHeight - value - CGRectGetMaxY(self.navigationController.navigationBar.frame));
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.view.frame = _rect;
}

@end
