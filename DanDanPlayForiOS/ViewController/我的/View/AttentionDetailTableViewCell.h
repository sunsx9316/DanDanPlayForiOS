//
//  AttentionDetailTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DETAIL_CELL_HEIGHT (110 + jh_isPad() * 30)

@interface AttentionDetailTableViewCell : UITableViewCell
@property (strong, nonatomic) JHPlayHistory *model;
@end
