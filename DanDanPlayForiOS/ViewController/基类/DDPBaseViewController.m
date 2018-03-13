//
//  DDPBaseViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

@interface DDPBaseViewController ()

@end

@implementation DDPBaseViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNavigationBarWithColor:[UIColor ddp_mainColor]];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName : [UIFont ddp_normalSizeFont]};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor ddp_backgroundColor];
    [self configLeftItem];
}

- (void)dealloc {
    [self.view hideAllHUD];
    NSLog(@"%@ dealloc", NSStringFromClass(self.class));
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

- (void)touchLeftItem:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)longProgressButton:(UILongPressGestureRecognizer *)aGesture {
    if (aGesture.state == UIGestureRecognizerStateBegan) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
