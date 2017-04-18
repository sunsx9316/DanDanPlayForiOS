//
//  FileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileViewController.h"
#import <WMPageController.h>
#import "LocalFileViewController.h"
#import "FTPViewController.h"

@interface FileViewController ()<WMPageControllerDataSource>
@property (strong, nonatomic) WMPageController *pageController;
@property (strong, nonatomic) NSArray <UIViewController *>*VCArr;

@end

@implementation FileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"文件";
    [self.view addSubview:self.pageController.view];
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController * _Nonnull)pageController {
    return self.VCArr.count;
}

- (__kindof UIViewController * _Nonnull)pageController:(WMPageController * _Nonnull)pageController viewControllerAtIndex:(NSInteger)index {
    return self.VCArr[index];
}

- (NSString * _Nonnull)pageController:(WMPageController * _Nonnull)pageController titleAtIndex:(NSInteger)index {
    if (index == 0) {
        return @"本地文件";
    }
    return @"网络传输";
}


#pragma mark - 懒加载
- (WMPageController *)pageController {
    if(_pageController == nil) {
        _pageController = [[WMPageController alloc] init];
        _pageController.dataSource = self;
        _pageController.titleColorNormal = [UIColor lightGrayColor];
        _pageController.titleColorSelected = MAIN_COLOR;
//        _pageController.menuBGColor = MAIN_COLOR;
        _pageController.titleSizeNormal = 13;
        _pageController.titleSizeSelected = 15;
        _pageController.menuViewContentMargin = 5;
        _pageController.itemMargin = 10;
        _pageController.menuHeight = 35;
//        _pageController.progressWidth = 70;
//        _pageController.automaticallyCalculatesItemWidths = YES;
        _pageController.menuViewStyle = WMMenuViewStyleLine;
        _pageController.menuViewLayoutMode = WMMenuViewLayoutModeLeft;
        [self addChildViewController:_pageController];
    }
    return _pageController;
}

- (NSArray<UIViewController *> *)VCArr {
    if (_VCArr == nil) {
        LocalFileViewController *fileVC = [[LocalFileViewController alloc] init];
        
        FTPViewController *ftpVC = [[FTPViewController alloc] init];
        
        _VCArr = @[fileVC, ftpVC];
    }
    return _VCArr;
}

@end
