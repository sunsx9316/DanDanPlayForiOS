//
//  HomePageBangumiProgressCollectionViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageBangumiProgressCollectionViewCell.h"

@interface HomePageBangumiProgressCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@end

@implementation HomePageBangumiProgressCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.nameLabel.font = SMALL_SIZE_FONT;
    self.progressLabel.font = VERY_SMALL_SIZE_FONT;
    self.descLabel.font = VERY_SMALL_SIZE_FONT;
    self.descLabel.textColor = [UIColor lightGrayColor];
    self.progressLabel.textColor = MAIN_COLOR;
}

- (void)setModel:(JHBangumiQueueIntro *)model {
    _model = model;
    [self.iconImgView jh_setImageWithURL:_model.imageUrl];
    self.nameLabel.text = _model.name;
    self.progressLabel.text = _model.episodeTitle;
    self.descLabel.text = _model.desc;
}

@end
