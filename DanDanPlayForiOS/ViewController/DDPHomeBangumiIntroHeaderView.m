//
//  DDPHomeBangumiIntroHeaderView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPHomeBangumiIntroHeaderView.h"

@interface DDPHomeBangumiIntroHeaderView ()
@property (strong, nonatomic) UIImageView *arrImgView;
@end

@implementation DDPHomeBangumiIntroHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.arrImgView];
        
        [self.arrImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(10);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.arrImgView);
            make.left.mas_equalTo(self.arrImgView.mas_right).mas_equalTo(5);
        }];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchHeaderView)]];
    }
    return self;
}

- (void)touchHeaderView {
    if (self.touchHeaderCallBack) {
        self.touchHeaderCallBack();
    }
}

#pragma mark - 懒加载
- (UIImageView *)arrImgView {
    if (_arrImgView == nil) {
        _arrImgView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"filter_arrow_down"] yy_imageByTintColor:[UIColor ddp_mainColor]]];
    }
    return _arrImgView;
}

@end
