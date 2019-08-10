//
//  DDPMainViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPMainVCItem.h"

@interface DDPMainViewController : UITabBarController
@property (strong, nonatomic, class, readonly) NSArray <DDPMainVCItem *>*items;
@end
