//
//  JHBaseViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBaseViewController.h"

@interface JHBaseViewController ()

@end

@implementation JHBaseViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNavigationBarWithColor:MAIN_COLOR];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : NORMAL_SIZE_FONT};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACK_GROUND_COLOR;
    [self configLeftItem];
}

- (void)dealloc {
    NSLog(@"%@ dealloc", NSStringFromClass(self.class));
}

#pragma mark - 私有方法
- (void)configLeftItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"comment_back_item"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchLeftItem:) forControlEvents:UIControlEventTouchUpInside];
    }];
    [self.navigationItem addLeftItemFixedSpace:item];
}

- (void)touchLeftItem:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
