//
//  DDPBaseNavigationController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseNavigationController.h"
#import "DDPBaseNavigationBar.h"

@interface DDPBaseNavigationController ()

@end

@implementation DDPBaseNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super initWithNavigationBarClass:[DDPBaseNavigationBar class] toolbarClass:nil]) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
        [self pushViewController:rootViewController animated:false];
    }
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#if DDPAPPTYPEISMAC
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:NO];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    return [super popViewControllerAnimated:NO];
}
#endif

@end
