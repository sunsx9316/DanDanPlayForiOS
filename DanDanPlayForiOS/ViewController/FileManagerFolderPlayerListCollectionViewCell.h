//
//  FileManagerFolderPlayerListCollectionViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerBaseCollectionViewCell.h"

@interface FileManagerFolderPlayerListCollectionViewCell : FileManagerBaseCollectionViewCell
@property (strong, nonatomic) VideoModel *model;
@property (strong, nonatomic) UILabel *titleLabel;
@end
