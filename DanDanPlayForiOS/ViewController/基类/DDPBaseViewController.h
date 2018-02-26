//
//  DDPBaseViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINavigationItem+Tools.h"
/**
 *  基类
 */
@interface DDPBaseViewController : UIViewController
- (void)configLeftItem;
- (void)touchLeftItem:(UIButton *)button;
@end
