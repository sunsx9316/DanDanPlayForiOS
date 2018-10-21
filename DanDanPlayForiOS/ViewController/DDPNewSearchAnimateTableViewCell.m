//
//  DDPNewSearchAnimateTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewSearchAnimateTableViewCell.h"
#import "NSDate+Tools.h"

@interface DDPNewSearchAnimateTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *episodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateLabel;

@end

@implementation DDPNewSearchAnimateTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.nameLabel.font = [UIFont ddp_normalSizeFont];
    let smallFont = [UIFont ddp_smallSizeFont];
    self.typeLabel.font = smallFont;
    self.timeLabel.font = smallFont;
    self.episodeLabel.font = smallFont;
    self.rateLabel.font = smallFont;
    
    self.nameLabel.text = nil;
    self.typeLabel.text = nil;
    self.timeLabel.text = nil;
    self.episodeLabel.text = nil;
    self.rateLabel.text = nil;
    
    let descColor = [UIColor lightGrayColor];
    self.typeLabel.textColor = descColor;
    self.timeLabel.textColor = descColor;
    self.episodeLabel.textColor = descColor;
    self.rateLabel.textColor = descColor;
}

- (void)setModel:(DDPSearchAnimeDetails *)model {
    _model = model;
    
    [self.imgView ddp_setImageWithURL:_model.imageUrl];
    self.nameLabel.text = _model.name;
    self.typeLabel.text = _model.typeDescription;
    
    let date = [NSDate dateWithDefaultFormatString:_model.startDate];
    self.timeLabel.text = [date searchAnimeTimeStyle];
    self.rateLabel.text = [NSString stringWithFormat:@"评分%.2lf", _model.rating];
    self.episodeLabel.text = [NSString stringWithFormat:@"共 %lu 集", (unsigned long)_model.episodeCount];
}

@end
