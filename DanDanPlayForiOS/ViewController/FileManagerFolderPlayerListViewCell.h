//
//  FileManagerFolderPlayerListViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerBaseViewCell.h"

@interface FileManagerFolderPlayerListViewCell : FileManagerBaseViewCell
@property (strong, nonatomic) VideoModel *model;
@property (strong, nonatomic) UILabel *titleLabel;
@end
