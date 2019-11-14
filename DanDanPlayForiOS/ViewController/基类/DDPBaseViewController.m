//
//  DDPBaseViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"
//#import <RTRootNavigationController/RTRootNavigationController.h>
#import "DDPBaseNavigationBar.h"
#import "DDPLoginViewController.h"

@interface DDPBaseViewController ()

@end

@implementation DDPBaseViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNavigationBarWithColor:[UIColor ddp_mainColor]];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont ddp_normalSizeFont]};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor ddp_backgroundColor];
    
    [self configLeftItem];
    [self configRightItem];
}

- (void)dealloc {
    [self.view hideAllHUD];
    LOG_DEBUG(DDPLogModuleOther, @"%@ dealloc", NSStringFromClass(self.class));
}

- (Class)ddp_navigationBarClass {
    return [DDPBaseNavigationBar class];
}

- (Class)rt_navigationBarClass {
    return [self ddp_navigationBarClass];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)showLoginAlert {
    return [self showLoginAlertWithAction:^{
#if DDPAPPTYPE != 1
        DDPLoginViewController *vc = [[DDPLoginViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
#endif
    }];
}

- (BOOL)showLoginAlertWithAction:(void(^)(void))alertAction {
    
    let flag = [DDPCacheManager shareCacheManager].currentUser.isLogin;
    
    if (flag == false) {
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"需要登录才能继续操作" preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (alertAction) {
                alertAction();
            }
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    
    return flag;
}

#pragma mark - 私有方法
- (void)configLeftItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment_back_item"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchLeftItem:) forControlEvents:UIControlEventTouchUpInside];
        [aButton addGestureRecognizer:({
            UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longProgressButton:)];
            ges.minimumPressDuration = 0.7;
            ges;
        })];
    }];
    [self.navigationItem addLeftItemFixedSpace:item];
}

- (void)configRightItem {
    
}

- (void)touchLeftItem:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)longProgressButton:(UILongPressGestureRecognizer *)aGesture {
    if (aGesture.state == UIGestureRecognizerStateBegan) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
