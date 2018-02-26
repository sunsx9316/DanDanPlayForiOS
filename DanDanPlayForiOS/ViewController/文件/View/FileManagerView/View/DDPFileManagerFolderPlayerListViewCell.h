//
//  DDPFileManagerFolderPlayerListViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileManagerBaseViewCell.h"

@interface DDPFileManagerFolderPlayerListViewCell : DDPFileManagerBaseViewCell
@property (strong, nonatomic) DDPVideoModel *model;
@property (strong, nonatomic) UILabel *titleLabel;
@end
