//
//  HomePageBannerView.m
//  TJSecurity
//
//  Created by JimHuang on 2017/6/9.
//  Copyright © 2017年 convoy. All rights reserved.
//

#import "HomePageBannerView.h"

@interface HomePageBannerView ()
@property (strong, nonatomic) UIView *gradualView;
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation HomePageBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.gradualView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.gradualView).mas_equalTo(UIEdgeInsetsMake(5, 10, 5, 10));
        }];
    }
    return self;
}

- (void)setModel:(JHBannerPage *)model {
    _model = model;
    self.titleLabel.text = _model.desc;
    [self.imgView jh_setImageWithURL:_model.imageURL];
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
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.numberOfLines = 2;
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIView *)gradualView {
    if (_gradualView == nil) {
        _gradualView = [[UIView alloc] init];
        _gradualView.backgroundColor = RGBACOLOR(0, 0, 0, 0.7);
        [self addSubview:_gradualView];
    }
    return _gradualView;
}

@end
