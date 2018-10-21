//
//  UIViewController+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIViewController+Tools.h"
#import "DDPPlayNavigationController.h"
#import "DDPMatchViewController.h"

@implementation UIViewController (Tools)
//- (void)setNavigationBarWithColor:(UIColor *)color {
//    if ([color isEqual:[UIColor clearColor]]) {
//        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
//        self.navigationController.navigationBar.translucent = YES;
//        // 将状态栏和导航条设置成透明
//        UIImage *image = [[UIImage alloc] init];
//        [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.shadowImage = image;
//    }
//    else {
//        self.navigationController.navigationBar.barTintColor = color;
//        self.navigationController.navigationBar.tintColor = color;
//        self.navigationController.navigationBar.translucent = NO;
//        [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
//    }
//}


- (void)tryAnalyzeVideo:(DDPVideoModel *)model {
    void(^jumpToMatchVCAction)(void) = ^{
        DDPMatchViewController *vc = [[DDPMatchViewController alloc] init];
        vc.model = model;
        vc.hidesBottomBarWhenPushed = YES;
        if ([self isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)self;
            [nav pushViewController:vc animated:true];
        }
        else {
            [self.navigationController pushViewController:vc animated:YES];
        }
    };
    
    if ([DDPCacheManager shareCacheManager].openFastMatch) {
        MBProgressHUD *aHUD = [MBProgressHUD defaultTypeHUDWithMode:MBProgressHUDModeAnnularDeterminate InView:self.view];
        [DDPMatchNetManagerOperation fastMatchVideoModel:model progressHandler:^(float progress) {
            aHUD.progress = progress;
            aHUD.label.text = ddp_danmakusProgressToString(progress);
        } completionHandler:^(DDPDanmakuCollection *responseObject, NSError *error) {
            model.danmakus = responseObject;
            [aHUD hideAnimated:NO];
            
            if (error) {
                [self.view showWithError:error];
            }
            else {
                if (responseObject == nil) {
                    jumpToMatchVCAction();
                }
                else {
                    DDPPlayNavigationController *nav = [[DDPPlayNavigationController alloc] initWithModel:model];
                    [self presentViewController:nav animated:YES completion:nil];
                }
            }
        }];
    }
    else {
        jumpToMatchVCAction();
    }
}

@end
