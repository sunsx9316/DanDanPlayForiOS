//
//  DDPBaseNavigationBar.h
//  AICoin
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 AICoin. All rights reserved.
//

#import "DDPBaseNavigationBar.h"

@implementation DDPBaseNavigationBar

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.translucent = false;
        
        [self changeCurrentTheme];
    }
    return self;
}

#pragma mark - 私有方法
- (void)changeCurrentTheme {
    UIFont *font = nil;
    
    if (@available(iOS 8.2, *)) {
        font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    }
    else {
        font = [UIFont boldSystemFontOfSize:17];
    }
    
    self.barTintColor = [UIColor ddp_mainColor];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[NSForegroundColorAttributeName] = [UIColor whiteColor];
    dic[NSFontAttributeName] = font;
    self.titleTextAttributes = dic;
}

@end
