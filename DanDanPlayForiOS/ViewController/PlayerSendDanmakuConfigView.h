//
//  PlayerSendDanmakuConfigView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  发送弹幕配置面板

#import <UIKit/UIKit.h>

@interface PlayerSendDanmakuConfigView : UIView
@property (copy, nonatomic) void(^selectedCallback)(UIColor *color, JHDanmakuMode mode);
- (void)show;
- (void)dismiss;
@end
