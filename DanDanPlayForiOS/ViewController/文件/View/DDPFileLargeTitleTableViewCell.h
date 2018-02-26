//
//  DDPFileLargeTitleTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPFileLargeTitleTableViewCell : UITableViewHeaderFooterView
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIImageView *arrowImgView;
@property (copy, nonatomic) void(^touchTitleCallBack)(DDPFileLargeTitleTableViewCell *cell);
@end
