//
//  PlayerSliderTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PlayerSliderTableViewCellType) {
    PlayerSliderTableViewCellTypeFontSize,
    PlayerSliderTableViewCellTypeSpeed,
};

@interface PlayerSliderTableViewCell : UITableViewCell
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) UILabel *currentValueLabel;
@property (strong, nonatomic) UILabel *totalValueLabel;
@property (assign, nonatomic) PlayerSliderTableViewCellType type;
@end
