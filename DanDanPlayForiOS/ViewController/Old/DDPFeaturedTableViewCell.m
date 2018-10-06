//
//  DDPFeaturedTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFeaturedTableViewCell.h"

@interface DDPFeaturedTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation DDPFeaturedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.font = [UIFont ddp_normalSizeFont];
    self.descLabel.font = [UIFont ddp_smallSizeFont];
    self.descLabel.textColor = [UIColor lightGrayColor];
}

- (void)setModel:(DDPHomeFeatured *)model {
    _model = model;
    [self.imgView ddp_setImageWithURL:_model.imageURL];
    self.nameLabel.text = _model.name;
    self.descLabel.text = _model.desc;
}

@end
