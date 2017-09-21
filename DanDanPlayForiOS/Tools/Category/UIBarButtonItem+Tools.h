//
//  UIBarButtonItem+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ItemConfigAction)(UIButton *aButton);

@interface UIBarButtonItem (Tools)
- (instancetype)initWithImage:(UIImage *)image configAction:(ItemConfigAction)configAction;
- (instancetype)initWithTitle:(NSString *)title configAction:(ItemConfigAction)configAction;
@end
