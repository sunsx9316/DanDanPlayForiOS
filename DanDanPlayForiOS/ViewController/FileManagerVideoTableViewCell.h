//
//  FileManagerVideoTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerBaseViewCell.h"

@interface FileManagerVideoTableViewCell : FileManagerBaseViewCell
@property (strong, nonatomic) JHSMBFile *model;
@property (strong, nonatomic) UILabel *titleLabel;
@end
