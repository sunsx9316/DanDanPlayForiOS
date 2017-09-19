//
//  JHDefaultPageViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHDefaultPageViewController.h"

@interface JHDefaultPageViewController ()

@end

@implementation JHDefaultPageViewController

- (instancetype)init {
    if (self = [super init]) {
        self.titleColorNormal = [UIColor lightGrayColor];
        self.titleColorSelected = MAIN_COLOR;
        self.titleSizeNormal = SMALL_SIZE_FONT.pointSize;
        self.titleSizeSelected = NORMAL_SIZE_FONT.pointSize;
        self.menuViewContentMargin = 5;
        self.itemMargin = 10;
        self.automaticallyCalculatesItemWidths = YES;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
    }
    return self;
}

@end
