//
//  PlayerNoticeView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PlayerNoticeView.h"
#import "JHEdgeButton.h"

@interface PlayerNoticeView ()
@property (strong, nonatomic) JHEdgeButton *closeButton;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation PlayerNoticeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.alpha = 0;
        _autoDismissTime = 3;
        
        [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(5);
            make.bottom.mas_offset(-5);
            make.width.mas_lessThanOrEqualTo(WIDTH * 0.4);
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
        _titleButton.titleLabel.font = SMALL_SIZE_FONT;
        _titleButton.titleLabel.numberOfLines = 0;
        _titleButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_titleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_titleButton addTarget:self action:@selector(touchTitleButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_titleButton];
    }
    return _titleButton;
}

- (JHEdgeButton *)closeButton {
    if (_closeButton == nil) {
        _closeButton = [[JHEdgeButton alloc] init];
        _closeButton.inset = CGSizeMake(10, 8);
        [_closeButton setImage:[UIImage imageNamed:@"player_close_button"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_closeButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_closeButton];
    }
    return _closeButton;
}

@end
