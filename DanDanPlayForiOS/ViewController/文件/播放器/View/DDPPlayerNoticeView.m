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
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(5);
            make.bottom.mas_offset(-5);
            make.width.mas_lessThanOrEqualTo(DDP_WIDTH * 0.4);
        }];
        
        [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_offset(-5);
            make.left.equalTo(self.titleLabel.mas_right).mas_offset(5);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return self.titleLabel.text;
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

- (void)touchTitleButton {
    [self dismiss];
    if (self.touchTitleCallBack) {
        self.touchTitleCallBack();
    }
}

- (void)touchCloseButton {
    [self dismiss];
    if (self.touchCloseButtonCallBack) {
        self.touchCloseButtonCallBack();
    }
}

#pragma mark - 懒加载

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_smallSizeFont];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.userInteractionEnabled = true;
        [_titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchTitleButton)]];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (_closeButton == nil) {
        DDPEdgeButton *aButton = [[DDPEdgeButton alloc] init];
        aButton.inset = CGSizeMake(10, 8);
        _closeButton = aButton;
        [_closeButton setImage:[UIImage imageNamed:@"player_close_button"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(touchCloseButton) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_closeButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_closeButton];
    }
    return _closeButton;
}

@end
