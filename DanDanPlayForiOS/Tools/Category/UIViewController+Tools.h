//
//  UIViewController+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Tools)
- (void)setNavigationBarWithColor:(UIColor *)color;


/**
 尝试解析视频 匹配到弹幕则跳转播放页 否则跳转匹配页

 @param model 视频
 */
- (void)tryAnalyzeVideo:(DDPVideoModel *)model;
@end
