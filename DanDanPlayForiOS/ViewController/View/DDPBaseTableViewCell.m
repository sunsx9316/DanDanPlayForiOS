//
//  DDPBaseTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/22.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBaseTableViewCell.h"

@implementation DDPBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

#pragma mark - Private Method
- (void)setup {
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = [UIColor ddp_cellHighlightColor];
    
    self.backgroundColor = [UIColor ddp_backgroundColor];
}

@end
