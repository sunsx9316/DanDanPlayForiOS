//
//  DDPBiliBiliSearchBangumiTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/3/10.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBiliBiliSearchBangumiTableViewCell.h"
#import "DDPEdgeButton.h"

@interface DDPBiliBiliSearchBangumiTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;
@property (weak, nonatomic) IBOutlet DDPEdgeButton *finishButton;
@property (weak, nonatomic) IBOutlet UIButton *danmakuCountButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalEpisodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefLabel;

@end

@implementation DDPBiliBiliSearchBangumiTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.backgroundColor = [UIColor ddp_cellHighlightColor];
    
    self.nameLabel.font = [UIFont ddp_normalSizeFont];
    self.danmakuCountButton.titleLabel.font = [UIFont ddp_smallSizeFont];
    self.briefLabel.font = [UIFont ddp_smallSizeFont];
    self.finishButton.titleLabel.font = [UIFont ddp_smallSizeFont];
    self.finishButton.inset = CGSizeMake(6, 2);
}

- (void)setModel:(DDPBiliBiliSearchBangumi *)model {
    _model = model;
    [self.coverImgView ddp_setImageWithURL:_model.cover resize:CGSizeMake(100, 140) roundedCornersRadius:6];
    self.finishButton.hidden = !_model.isFinish;
    [self.danmakuCountButton setTitle:[NSString stringWithFormat:@"%lu", (unsigned long)_model.danmakuCount] forState:UIControlStateNormal];
    self.nameLabel.text = _model.name;
    self.totalEpisodeLabel.text = [NSString stringWithFormat:@"共%lu集", (unsigned long)_model.totalCount];
    self.briefLabel.text = _model.desc;
}

@end
