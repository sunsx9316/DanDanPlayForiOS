//
//  DDPMarqueeView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/1.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPMarqueeView.h"
#import <Masonry/Masonry.h>

@interface DDPMarqueeView ()

@end

@implementation DDPMarqueeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.label];
        self.clipsToBounds = true;
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_equalTo(0);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}


- (void)startAnimate {
    [self stopAnimate];
    
    let size = [self.label.text sizeForFont:self.label.font ?: [UIFont ddp_normalSizeFont] size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping];
    
    CGFloat duration = size.width * 0.02;
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.label.transform = CGAffineTransformMakeTranslation(-size.width, 0);
    } completion:^(BOOL finished) {
        self.label.transform = CGAffineTransformMakeTranslation(size.width, 0);
        [UIView animateWithDuration:2 * duration delay:0 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionRepeat animations:^{
            self.label.transform = CGAffineTransformMakeTranslation(-size.width, 0);
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)stopAnimate {
    [self.label.layer removeAllAnimations];
    self.label.transform = CGAffineTransformIdentity;
}

#pragma mark - 懒加载
- (UILabel *)label {
    if (_label == nil) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont ddp_normalSizeFont];
    }
    return _label;
}

@end
