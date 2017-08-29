//
//  PlayerSliderTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  带一个slider的cell

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PlayerSliderTableViewCellType) {
    PlayerSliderTableViewCellTypeFontSize,
    PlayerSliderTableViewCellTypeSpeed,
    PlayerSliderTableViewCellTypeOpacity,
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
