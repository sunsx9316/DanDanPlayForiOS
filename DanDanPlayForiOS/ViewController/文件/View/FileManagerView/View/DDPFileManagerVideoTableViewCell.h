//
//  DDPFileManagerVideoTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileManagerBaseViewCell.h"

@interface DDPFileManagerVideoTableViewCell : DDPFileManagerBaseViewCell
@property (strong, nonatomic) DDPSMBFile *model;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *fileTypeLabel;
@end
