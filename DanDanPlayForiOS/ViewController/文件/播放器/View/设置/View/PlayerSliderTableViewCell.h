//
//  PlayerSliderTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  带一个slider的cell

#import <UIKit/UIKit.h>


/**
 滚动条类型

 - PlayerSliderTableViewCellTypeFontSize: 文字大小
 - PlayerSliderTableViewCellTypeSpeed: 速度
 - PlayerSliderTableViewCellTypeOpacity: 透明度
 - PlayerSliderTableViewCellTypeDanmakuLimit: 同屏弹幕数量
 - PlayerSliderTableViewCellTypeRate: 播放速率
 */
typedef NS_ENUM(NSUInteger, PlayerSliderTableViewCellType) {
    PlayerSliderTableViewCellTypeFontSize,
    PlayerSliderTableViewCellTypeSpeed,
    PlayerSliderTableViewCellTypeOpacity,
    PlayerSliderTableViewCellTypeDanmakuLimit,
    PlayerSliderTableViewCellTypeRate,
};

@interface PlayerSliderTableViewCell : UITableViewCell
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *currentValueLabel;
@property (strong, nonatomic) UILabel *totalValueLabel;
@property (assign, nonatomic) PlayerSliderTableViewCellType type;
@property (copy, nonatomic) void(^touchSliderCallback)(PlayerSliderTableViewCell *aCell);
@property (copy, nonatomic) void(^touchSliderUpCallback)(PlayerSliderTableViewCell *aCell);
@end
