//
//  FileManagerFolderShortCollectionViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/29.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerFolderShortCollectionViewCell.h"

@implementation FileManagerFolderShortCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.iconImgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(5);
            make.right.mas_offset(-5);
        }];
        
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImgView.mas_bottom).mas_offset(5);
            make.left.mas_offset(5);
            make.right.bottom.mas_offset(-5);
        }];
        
        [self.titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end
