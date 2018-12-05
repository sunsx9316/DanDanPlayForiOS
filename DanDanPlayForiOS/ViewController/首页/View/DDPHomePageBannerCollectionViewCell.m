//
//  DDPHomePageBannerCollectionViewCell.m
//  TJSecurity
//
//  Created by JimHuang on 2017/6/9.
//  Copyright © 2017年 convoy. All rights reserved.
//

#import "DDPHomePageBannerCollectionViewCell.h"
#import "UIView+Tools.h"

@interface DDPHomePageBannerCollectionViewCell ()
@property (strong, nonatomic) UIView *gradualView;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *contentLabel;

@property (strong, nonatomic) UIView *buttonHolderView;
@end

@implementation DDPHomePageBannerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.gradualView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(self.imgView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.gradualView).mas_offset(10);
            make.left.equalTo(self.gradualView).mas_offset(5);
            make.right.equalTo(self.gradualView).mas_offset(-10);
        }];
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(5);
            make.left.right.equalTo(self.titleLabel);
            make.bottom.equalTo(self.gradualView).mas_offset(-10);
        }];
    }
    return self;
}

- (void)setBanner:(DDPNewBanner *)banner {
    _banner = banner;
    self.titleLabel.text = _banner.name;
    self.contentLabel.text = _banner.desc;
    [self.imgView ddp_setImageWithURL:_banner.imageUrl];
}

#pragma mark - 懒加载
- (UIImageView *)imgView {
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        [self addSubview:_imgView];
    }
    return _imgView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 2;
        [_titleLabel setRequiredContentVerticalResistancePriority];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont ddp_smallSizeFont];
        _contentLabel.textColor = [UIColor ddp_veryLightGrayColor];
        _contentLabel.numberOfLines = 3;
        [self addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UIView *)gradualView {
    if (_gradualView == nil) {
        _gradualView = [[UIView alloc] init];
        _gradualView.backgroundColor = DDPRGBAColor(0, 0, 0, DEFAULT_BLACK_ALPHA);
        [self addSubview:_gradualView];
    }
    return _gradualView;
}


@end

