//
//  UIBarButtonItem+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIBarButtonItem+Tools.h"

@implementation UIBarButtonItem (Tools)

- (instancetype)initWithImage:(UIImage *)image configAction:(ItemConfigAction)configAction {
    UIButton *aButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    aButton.titleLabel.font = NORMAL_SIZE_FONT;
    [aButton setImage:image forState:UIControlStateNormal];
    if (configAction) configAction(aButton);
    return [self initWithCustomView:aButton];
}

- (instancetype)initWithTitle:(NSString *)title configAction:(ItemConfigAction)configAction {
    UIButton *aButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    aButton.titleLabel.font = NORMAL_SIZE_FONT;
    [aButton setTitle:title forState:UIControlStateNormal];
    [aButton sizeToFit];
    if (configAction) configAction(aButton);
    
    return [self initWithCustomView:aButton];
}

@end
