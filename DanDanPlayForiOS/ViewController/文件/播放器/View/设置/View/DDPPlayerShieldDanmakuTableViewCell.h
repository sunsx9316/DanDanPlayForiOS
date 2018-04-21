//
//  DDPPlayerShieldDanmakuTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/4/16.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 cell类型
 
 - DDPPlayerShadowStyleTableViewCellTypeShadow: 边缘特效
 - DDPPlayerShadowStyleTableViewCellTypeField: 屏蔽弹幕
 */
typedef NS_ENUM(NSUInteger, DDPPlayerShieldDanmakuTableViewCellType) {
    DDPPlayerShieldDanmakuTableViewCellTypeShadow = 1,
    DDPPlayerShieldDanmakuTableViewCellTypeField,
};

@interface DDPPlayerShieldDanmakuTableViewCell : UITableViewCell

@property (assign, nonatomic) DDPPlayerShieldDanmakuTableViewCellType type;

@end
