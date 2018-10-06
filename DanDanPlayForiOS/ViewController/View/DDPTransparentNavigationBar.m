//
//  DDPTransparentNavigationBar.h
//  AICoin
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 AICoin. All rights reserved.
//  透明导航栏

#import "DDPTransparentNavigationBar.h"

@interface DDPTransparentNavigationBar ()
@property (nonatomic, strong) UIView *bgView;
@end

@implementation DDPTransparentNavigationBar

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.translucent = true;
        
        _upperBound = CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 44;
        _lowerBound = 200.0;
        [self updateTransparentWithOffset:CGPointZero];
        
        [self setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:[[UIImage alloc] init]];
        [self addSubview:self.bgView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = [UIApplication sharedApplication].statusBarFrame;
    rect.origin.y -= rect.size.height;
    rect.size.height += self.bounds.size.height;
    
    self.bgView.frame = rect;
    
    [self sendSubviewToBack:self.bgView];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *aView = [super hitTest:point withEvent:event];

    if (aView == self || [self.subviews containsObject:aView]) {
        return nil;
    }
    return aView;
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    self.bgView.backgroundColor = _bgColor;
}

- (void)setBgAlpha:(CGFloat)bgAlpha {
    _bgAlpha = bgAlpha;
    self.bgView.alpha = _bgAlpha;
}

- (void)updateTransparentWithOffset:(CGPoint)offset {
    [self updateTransparentWithOffset:offset titleView:nil];
}

- (void)updateTransparentWithOffset:(CGPoint)offset titleView:(UIView *)titleView {
    if (offset.y > 0) {
        //滚动超过头视图
        CGFloat offsetY = MIN(offset.y / _lowerBound, 1);
        self.alpha = 1;
        self.bgAlpha = offsetY;
        titleView.alpha = offsetY;
    }
    else {
        //滚动超过导航栏
        CGFloat offsetY = MIN(-offset.y / _upperBound, 1);
        self.bgAlpha = 0;
        titleView.alpha = 0;
        self.alpha = 1 - offsetY;
    }
}

#pragma mark - 懒加载
- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
    }
    return _bgView;
}

@end
