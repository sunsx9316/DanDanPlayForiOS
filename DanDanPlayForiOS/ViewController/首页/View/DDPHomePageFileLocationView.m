//
//  DDPHomePageFileLocationView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/11.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPHomePageFileLocationView.h"
#import "DDPFileManagerViewController.h"
#import "DDPSMBViewController.h"
#import "DDPQRScannerViewController.h"
#import "DDPLinkFileManagerViewController.h"

@implementation DDPHomePageFileLocationView

- (IBAction)touchPhoneButton:(UIButton *)sender {
    DDPFileManagerViewController *vc = [[DDPFileManagerViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    vc.file = ddp_getANewRootFile();
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchSMBButton:(UIButton *)sender {
    DDPSMBViewController *vc = [[DDPSMBViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)touchComputerButton:(UIButton *)sender {
    //已经登录
    if ([DDPCacheManager shareCacheManager].linkInfo) {
        DDPLinkFileManagerViewController *vc = [[DDPLinkFileManagerViewController alloc] init];
        vc.file = ddp_getANewLinkRootFile();
        vc.hidesBottomBarWhenPushed = YES;
        [self.viewController.navigationController pushViewController:vc animated:YES];
    }
    else {
        DDPQRScannerViewController *vc = [[DDPQRScannerViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        @weakify(self)
        vc.linkSuccessCallBack = ^(DDPLinkInfo *info) {
            @strongify(self)
            if (!self) return;
            
            NSMutableArray *arr = [self.viewController.navigationController.viewControllers mutableCopy];
            [arr removeLastObject];
            
            
            //连接成功直接跳转到列表
            DDPLinkFileManagerViewController *avc = [[DDPLinkFileManagerViewController alloc] init];
            avc.file = ddp_getANewLinkRootFile();
            avc.hidesBottomBarWhenPushed = YES;
            [arr addObject:avc];
            [self.viewController.navigationController setViewControllers:arr animated:YES];
        };
        [self.viewController.navigationController pushViewController:vc animated:YES];
    }
}



@end
