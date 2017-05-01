//
//  MatchTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/20.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "MatchTableViewCell.h"

@interface MatchTableViewCell ()

@end

@implementation MatchTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = VERY_LIGHT_GRAY_COLOR;
        
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
        }];
        
        [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.right.mas_offset(-10);
            make.bottom.mas_offset(-10);
            make.width.mas_equalTo(self).multipliedBy(0.5);
        }];

    }
    return self;
}

- (void)setModel:(JHMatche *)model {
    _model = model;
    self.titleLabel.text = _model.animeTitle;
    self.detailLabel.text = _model.name;
}

@end
