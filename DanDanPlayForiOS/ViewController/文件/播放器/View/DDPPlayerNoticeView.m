//
//  DDPPlayerNoticeView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerNoticeView.h"
#import "DDPEdgeButton.h"

@interface DDPPlayerNoticeView ()
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation DDPPlayerNoticeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.alpha = 0;
        _autoDismissTime = 4;
        
        [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(5);
            make.bottom.mas_offset(-5);
            make.width.mas_lessThanOrEqualTo(DDP_WIDTH * 0.4);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_offset(-5);
            make.left.equalTo(self.titleButton.mas_right).mas_offset(5);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)show {

    if (self.superview == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
    
    self.transform = CGAffineTransformMakeTranslation(-20, 0);
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        @weakify(self)
        self.timer = [NSTimer scheduledTimerWithTimeInterval:_autoDismissTime block:^(NSTimer * _Nonnull timer) {
            @strongify(self);
            if (!self) return;
            
            [self dismiss];
            
        } repeats:NO];
    }];
}

- (void)dismiss {
    
    [self.timer invalidate];
    
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeTranslation(-20, 0);
    } completion:^(BOOL finished) {
//        [self removeFromSuperview];
    }];
}

- (void)touchTitleButton:(UIButton *)button {
    [self dismiss];
    if ([self.delegate respondsToSelector:@selector(playerNoticeViewDidTouchButton)]) {
        [self.delegate playerNoticeViewDidTouchButton];
    }
}

#pragma mark - 懒加载
- (UIButton *)titleButton {
    if (_titleButton == nil) {
        _titleButton = [[UIButton alloc] init];
        _titleButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        _titleButton.titleLabel.numberOfLines = 0;
        _titleButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleButton addTarget:self action:@selector(touchTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleButton];
    }
    return _titleButton;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        DDPEdgeButton *aButton = [[DDPEdgeButton alloc] init];
        aButton.inset = CGSizeMake(10, 8);
        _closeButton = aButton;
        [_closeButton setImage:[UIImage imageNamed:@"player_close_button"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_closeButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_closeButton];
    }
    return _closeButton;
}

@end
