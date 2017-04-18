//
//  UIButton+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Tools)
- (void)jh_setImageWithURL:(nullable NSURL *)imageURL
                  forState:(UIControlState)state;
@end
