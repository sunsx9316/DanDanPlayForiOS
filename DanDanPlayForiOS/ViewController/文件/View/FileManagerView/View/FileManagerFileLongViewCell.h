//
//  FileManagerFileLongViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerBaseViewCell.h"

@interface FileManagerFileLongViewCell : FileManagerBaseViewCell
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *lastPlayTimeButton;
@property (strong, nonatomic) UIImageView *bgImgView;
@property (strong, nonatomic) id model;
@end
