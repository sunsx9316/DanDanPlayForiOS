//
//  DDPTextHeaderView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPTextHeaderView.h"

@implementation DDPTextHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
#if DDPAPPTYPEISMAC
        self.contentView.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
        [self.contentView.layer setLayerShadow:DDPRGBAColor(20, 20, 20, 0.15) offset:CGSizeMake(0, 1) radius:1.5];
#else        
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.75 alpha:1];
        [self.layer setLayerShadow:DDPRGBAColor(20, 20, 20, 0.15) offset:CGSizeMake(0, 1) radius:1.5];
#endif
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.mas_equalTo(10);
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

@end
