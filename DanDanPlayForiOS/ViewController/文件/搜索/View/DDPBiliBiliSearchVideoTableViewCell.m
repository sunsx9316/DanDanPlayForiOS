//
//  DDPBiliBiliSearchVideoTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/3/10.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBiliBiliSearchVideoTableViewCell.h"
#import "DDPEdgeLabel.h"

@interface DDPBiliBiliSearchVideoTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet DDPEdgeLabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

@implementation DDPBiliBiliSearchVideoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = [UIColor ddp_cellHighlightColor];
    
    self.timeLabel.inset = CGSizeMake(8, 2);
    self.nameLabel.font = [UIFont ddp_normalSizeFont];
    self.timeLabel.font = [UIFont ddp_smallSizeFont];
}

- (void)setModel:(DDPBiliBiliSearchVideo *)model {
    _model = model;
    [self.iconImgView ddp_setImageWithURL:_model.pic resize:CGSizeMake(130, 80) roundedCornersRadius:6];
    self.nameLabel.text = _model.name;
    [self.playButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)_model.play] forState:UIControlStateNormal];
    self.timeLabel.text = _model.duration;
}

@end
