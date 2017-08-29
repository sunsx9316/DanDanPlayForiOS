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

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[FileManagerNavigationBar class] toolbarClass:nil]) {
        [self setViewControllers:@[rootViewController]];
    }
    return self;
}


@end
