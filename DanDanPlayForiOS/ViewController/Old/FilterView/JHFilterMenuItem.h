//
//  JHFilterMenuItem.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <WMPageController/WMPageController.h>

@interface JHFilterMenuItem : WMMenuItem
@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIView *lineView;

- (instancetype)initWithItem:(WMMenuItem *)item;
@end
