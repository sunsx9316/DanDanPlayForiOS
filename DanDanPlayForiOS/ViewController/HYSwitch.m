//
//  HYSwitch.m
//  Test
//
//  Created by Shadow on 14-5-17.
//  Copyright (c) 2014年 Shadow. All rights reserved.
//

#import "HYSwitch.h"

#define DEFAULT_ON_COLOR [UIColor colorWithRed:76/255.f green:216/255.f blue:100/255.f alpha:1]

@interface HYSwitch ()
@property (nonatomic, strong) UIView *circleView;
@property (strong, nonatomic) UILabel *onLabel;
@property (strong, nonatomic) UILabel *offLabel;
@property (nonatomic, getter = isOn) BOOL on;
@end

@implementation HYSwitch
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.circleView];
        
        // Initialization code
        [self setDefaultValue];
        
        self.backgroundColor = self.offColor;
        
        self.layer.cornerRadius = CGRectGetHeight(frame)/2;
        self.layer.masksToBounds = YES;
        
        [self setupGestures];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.onLabel sizeToFit];
    CGRect frame = self.onLabel.frame;
    frame.origin = CGPointMake((CGRectGetWidth(self.frame) - CGRectGetWidth(self.circleView.frame) - CGRectGetWidth(self.onLabel.frame)) / 2, (CGRectGetHeight(self.frame) - CGRectGetHeight(self.onLabel.frame)) / 2);
    self.onLabel.frame = frame;
    
    [self.offLabel sizeToFit];
    frame = self.offLabel.frame;
    frame.origin = CGPointMake((CGRectGetWidth(self.frame) - CGRectGetWidth(self.circleView.frame) - CGRectGetWidth(self.offLabel.frame)) / 2 + CGRectGetWidth(self.circleView.frame), (CGRectGetHeight(self.frame) - CGRectGetHeight(self.offLabel.frame)) / 2);
    self.offLabel.frame = frame;
}

- (void)setDefaultValue {
    self.onColor = DEFAULT_ON_COLOR;
    self.offColor = [UIColor lightGrayColor];
    self.buttonColor = [UIColor whiteColor];
    self.onTextColor = [UIColor whiteColor];
    self.offTextColor = [UIColor whiteColor];
    self.onLabel.alpha = 0;
    self.offLabel.alpha = 1;
}

- (void)setupGestures {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHandler:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panHandler:)];
    [self addGestureRecognizer:pan];
}

#pragma mark - setter
- (void)setButtonColor:(UIColor *)buttonColor {
    _buttonColor = buttonColor;
    self.circleView.backgroundColor = buttonColor;
}

- (void)setOnColor:(UIColor *)onColor {
    _onColor = onColor;
    if (self.isOn) {
        self.backgroundColor = onColor;
    }
}

- (void)setOffColor:(UIColor *)offColor {
    _offColor = offColor;
    if (!self.isOn) {
        self.backgroundColor = offColor;
    }
}

- (void)setOnText:(NSString *)onText {
    _onText = onText;
    self.onLabel.text = _onText;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setOffText:(NSString *)offText {
    _offText = offText;
    self.offLabel.text = _offText;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setOffTextColor:(UIColor *)offTextColor {
    _offTextColor = offTextColor;
    self.offLabel.textColor = _offTextColor;
}

- (void)setOnTextColor:(UIColor *)onTextColor {
    _onTextColor = onTextColor;
    self.onLabel.textColor = _onTextColor;
}

#pragma mark - 设置开关方法
- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated {
    self.on = on;
    if (on) {
        [self onAnimationWithAnimated:animated];
    } else {
        [self offAnimationWithAnimated:animated];
    }
}

- (void)setSwitchOn:(BOOL)on animated:(BOOL)animated doAction:(BOOL)action {
    [self setSwitchOn:on animated:animated];
    if (action) {
        [self performAction];
    }
}

#pragma mark - 手势处理

static BOOL oldOn = NO;
- (void)panHandler:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateBegan) {
        //手势开始的时候记录开关的当前状态.
        oldOn = self.isOn;
    }
    
    if (pan.state != UIGestureRecognizerStateEnded) {
        CGPoint point = [pan translationInView:self];
        if (point.x > 0) {
            [self setSwitchOn:YES animated:YES];
        } else if (point.x < 0) {
            [self setSwitchOn:NO animated:YES];
        }
    } else {
        //如果pan手势结束后的开关状态与开始记录的旧状态不同, 则执行action.
        if (oldOn != self.isOn) {
            [self performAction];
        }
    }
    
    [pan setTranslation:CGPointZero inView:self];
}

- (void)tapHandler:(UITapGestureRecognizer *)tap {
    [self setSwitchOn:!self.isOn animated:YES];
    [self performAction];
}

#pragma mark - 其他
- (void)performAction {
    if (self.action) {
        self.action(self.isOn);
    }
}

- (void)onAnimationWithAnimated:(BOOL)animated {
    void(^actionBlock)() = ^{
        self.backgroundColor = self.onColor;
        self.circleView.center = CGPointMake(CGRectGetWidth(self.frame) - CGRectGetHeight(self.frame)/2, CGRectGetHeight(self.frame)/2);
        self.offLabel.alpha = 0;
        self.onLabel.alpha = 1;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:actionBlock completion:^(BOOL finished) {
            
        }];
    }
    else {
        actionBlock();
    }
    
}

- (void)offAnimationWithAnimated:(BOOL)animated {
    
    void(^actionBlock)() = ^{
        self.backgroundColor = self.offColor;
        self.circleView.center = CGPointMake(CGRectGetHeight(self.frame)/2,
                                             CGRectGetHeight(self.frame)/2);
        self.offLabel.alpha = 1;
        self.onLabel.alpha = 0;
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25f animations:actionBlock completion:nil];
    }
    else {
        actionBlock();
    }
}

#pragma mark - 懒加载
- (UILabel *)offLabel {
    if (_offLabel == nil) {
        _offLabel = [[UILabel alloc] init];
        _offLabel.font = [UIFont systemFontOfSize:15];
        _offLabel.textColor = [UIColor whiteColor];
        [self insertSubview:_offLabel belowSubview:self.circleView];
    }
    return _offLabel;
}

- (UILabel *)onLabel {
    if (_onLabel == nil) {
        _onLabel = [[UILabel alloc] init];
        _onLabel.font = [UIFont systemFontOfSize:15];
        _onLabel.textColor = [UIColor whiteColor];
        [self insertSubview:_onLabel belowSubview:self.circleView];
    }
    return _onLabel;
}

- (UIView *)circleView {
    if (_circleView == nil) {
        CGRect frame = self.bounds;
        _circleView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, CGRectGetHeight(frame) - 2, CGRectGetHeight(frame) - 2)];
        _circleView.layer.cornerRadius = CGRectGetHeight(frame) / 2 - 1;
        _circleView.layer.masksToBounds = YES;
        _circleView.backgroundColor = self.buttonColor;
    }
    return _circleView;
}

@end
