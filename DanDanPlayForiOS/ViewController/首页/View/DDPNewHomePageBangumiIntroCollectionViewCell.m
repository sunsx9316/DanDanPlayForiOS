//
//  DDPNewHomePageBangumiIntroCollectionViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewHomePageBangumiIntroCollectionViewCell.h"
#import "DDPEdgeLabel.h"
#import "DDPAttentionDetailViewController.h"

@interface DDPNewHomePageBangumiIntroCollectionViewCell ()
@property (weak, nonatomic) IBOutlet DDPEdgeLabel *rateLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;

@property (weak, nonatomic) IBOutlet DDPEdgeLabel *nameLabel;


@end

@implementation DDPNewHomePageBangumiIntroCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.rateLabel.backgroundColor = [UIColor ddp_mainColor];
    self.rateLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.rateLabel.text = nil;
    self.nameLabel.text = nil;
    
    self.nameLabel.inset = CGSizeMake(0, 10);
    self.rateLabel.inset = CGSizeMake(10, 10);
    self.rateLabel.font = [UIFont ddp_smallSizeFont];
    self.nameLabel.font = [UIFont ddp_smallSizeFont];
    
    let mainColor = [UIColor ddp_mainColor];
    [self.likeButton setBackgroundImage:[[UIImage imageNamed:@"home_unlike"] imageByTintColor:mainColor] forState:UIControlStateSelected];
    [self.likeButton setBackgroundImage:[[UIImage imageNamed:@"home_like"] imageByTintColor:[UIColor grayColor]] forState:UIControlStateNormal];
    self.likeButton.layer.shadowRadius = 3;
    self.likeButton.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.likeButton.layer.shadowOpacity = 1;
    self.likeButton.layer.shadowOffset = CGSizeMake(0, 0);
    self.likeButton.ddp_hitTestSlop = UIEdgeInsetsMake(-10, -10, -10, -10);
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchItem:)]];
}

- (void)setModel:(DDPNewBangumiIntro *)model {
    _model = model;
    
    [self.imgView ddp_setImageWithURL:_model.imageUrl];
    self.rateLabel.text = [NSString stringWithFormat:@"%.1lf", _model.rating];
    self.nameLabel.text = _model.name;
    self.likeButton.selected = _model.isFavorited;
}


- (IBAction)touchLikeButton:(UIButton *)sender {
    if (self.touchLikeButtonCallBack) {
        self.touchLikeButtonCallBack(self.model);
    }
}


- (void)touchItem:(UITapGestureRecognizer *)ges {
    let model = self.model;
    DDPAttentionDetailViewController *vc = [[DDPAttentionDetailViewController alloc] init];
    vc.animateId = model.identity;
    vc.isOnAir = YES;
    vc.attentionCallBack = self.attentionCallBack;
    vc.hidesBottomBarWhenPushed = YES;
    [self.viewController.navigationController pushViewController:vc animated:YES];
}

@end
