//
//  DDPDefaultPageViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDefaultPageViewController.h"

@interface DDPDefaultPageViewController ()

@end

@implementation DDPDefaultPageViewController

- (instancetype)init {
    if (self = [super init]) {
        self.titleColorNormal = [UIColor lightGrayColor];
        self.titleColorSelected = [UIColor ddp_mainColor];
        self.titleSizeNormal = [UIFont ddp_smallSizeFont].pointSize;
        self.titleSizeSelected = [UIFont ddp_normalSizeFont].pointSize;
        self.menuViewContentMargin = 5;
        self.itemMargin = 10;
        self.automaticallyCalculatesItemWidths = YES;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

@end
