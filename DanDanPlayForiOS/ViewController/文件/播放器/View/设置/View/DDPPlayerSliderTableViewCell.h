//
//  DDPPlayerSliderTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  带一个slider的cell

#import <UIKit/UIKit.h>


/**
 滚动条类型

 - DDPPlayerSliderTableViewCellTypeFontSize: 文字大小
 - DDPPlayerSliderTableViewCellTypeSpeed: 速度
 - DDPPlayerSliderTableViewCellTypeOpacity: 透明度
 - DDPPlayerSliderTableViewCellTypeDanmakuLimit: 同屏弹幕数量
 - DDPPlayerSliderTableViewCellTypeRate: 播放速率
 */
typedef NS_ENUM(NSUInteger, DDPPlayerSliderTableViewCellType) {
    DDPPlayerSliderTableViewCellTypeFontSize,
    DDPPlayerSliderTableViewCellTypeSpeed,
    DDPPlayerSliderTableViewCellTypeOpacity,
    DDPPlayerSliderTableViewCellTypeDanmakuLimit,
    DDPPlayerSliderTableViewCellTypeRate,
};

@interface DDPPlayerSliderTableViewCell : UITableViewCell
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *currentValueLabel;
@property (strong, nonatomic) UILabel *totalValueLabel;
@property (assign, nonatomic) DDPPlayerSliderTableViewCellType type;
@property (copy, nonatomic) void(^touchSliderCallback)(DDPPlayerSliderTableViewCell *aCell);
@property (copy, nonatomic) void(^touchSliderUpCallback)(DDPPlayerSliderTableViewCell *aCell);
@end
