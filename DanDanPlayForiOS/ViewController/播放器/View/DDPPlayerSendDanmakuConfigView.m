//
//  DDPPlayerSendDanmakuConfigView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerSendDanmakuConfigView.h"
#import <NKOColorPickerView.h>
#import "DDPBlurView.h"

@interface DDPPlayerSendDanmakuConfigView ()
@property (strong, nonatomic) NKOColorPickerView *colorPickerView;

@property (strong, nonatomic) UIButton *normalButton;
@property (strong, nonatomic) UIButton *topButton;
@property (strong, nonatomic) UIButton *bottomButton;
@property (strong, nonatomic) DDPBlurView *contentView;
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *resetButton;
@end

@implementation DDPPlayerSendDanmakuConfigView
{
    UIButton *_selectedButton;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.alpha = 0;
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10 + ddp_isPad() * 20);
            make.bottom.mas_offset(-10 - ddp_isPad() * 20);
            make.centerX.mas_equalTo(0);
        }];
        
        [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_right);
            make.right.mas_offset(0);
            make.centerY.mas_equalTo(0);
        }];
        
        DDPDanmakuMode mode = [DDPCacheManager shareCacheManager].sendDanmakuMode;
        if (mode == DDPDanmakuModeBottom) {
            self.bottomButton.selected = YES;
            _selectedButton = self.bottomButton;
        }
        else if (mode == DDPDanmakuModeTop) {
            self.topButton.selected = YES;
            _selectedButton = self.topButton;
        }
        else {
            self.normalButton.selected = YES;
            _selectedButton = self.normalButton;
        }
        
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)show {
    if (self.superview == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 私有方法

- (void)touchResetButton:(UIButton *)sender {
    [DDPCacheManager shareCacheManager].sendDanmakuColor = [UIColor whiteColor];
    [DDPCacheManager shareCacheManager].sendDanmakuMode = DDPDanmakuModeNormal;
    
    self.colorPickerView.color = [UIColor whiteColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    _selectedButton.selected = NO;
    self.normalButton.selected = YES;
    _selectedButton = self.normalButton;
}

- (UIImage *)buttonBgImgWithFlag:(BOOL)isSelected index:(NSInteger)index {
    if (isSelected) {
        UIImage *img = [UIImage imageWithColor:[UIColor ddp_mainColor] size:CGSizeMake(10, 10)];
        if (index == 0) {
            img = [img yy_imageByRoundCornerRadius:4 corners:UIRectCornerTopLeft | UIRectCornerTopRight borderWidth:0 borderColor:nil borderLineJoin:kCGLineJoinMiter];
            return [img resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
        else if (index == 1) {
            return img;
        }
        else {
            img = [img yy_imageByRoundCornerRadius:4 corners:UIRectCornerBottomLeft | UIRectCornerBottomRight borderWidth:0 borderColor:nil borderLineJoin:kCGLineJoinMiter];
            return [img resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
        }
    }
    
    UIImage *img = [UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(10, 10)];
    if (index == 0) {
        img = [img yy_imageByRoundCornerRadius:4 corners:UIRectCornerTopLeft | UIRectCornerTopRight borderWidth:1 borderColor:[UIColor ddp_mainColor] borderLineJoin:kCGLineJoinMiter];
        return [img resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    }
    else if (index == 1) {
        img = [img yy_imageByRoundCornerRadius:0 corners:kNilOptions borderWidth:1 borderColor:[UIColor ddp_mainColor] borderLineJoin:kCGLineJoinMiter];
        return [img resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    }
    else {
        img = [img yy_imageByRoundCornerRadius:4 corners:UIRectCornerBottomLeft | UIRectCornerBottomRight borderWidth:1 borderColor:[UIColor ddp_mainColor] borderLineJoin:kCGLineJoinMiter];
        return [img resizableImageWithCapInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    }
}

- (void)touchButton:(UIButton *)sender {
    _selectedButton.selected = NO;
    _selectedButton = sender;
    _selectedButton.selected = YES;
    
    DDPDanmakuMode _danmakuMode;
    if (sender == self.topButton) {
        _danmakuMode = DDPDanmakuModeTop;
    }
    else if (sender == self.bottomButton) {
        _danmakuMode = DDPDanmakuModeBottom;
    }
    else {
        _danmakuMode = DDPDanmakuModeNormal;
    }
    
    [DDPCacheManager shareCacheManager].sendDanmakuMode = _danmakuMode;
    
    if (self.selectedCallback) {
        self.selectedCallback([DDPCacheManager shareCacheManager].sendDanmakuColor, _danmakuMode);
    }
}


#pragma mark - 懒加载

- (DDPBlurView *)contentView {
    if (_contentView == nil) {
        _contentView = [[DDPBlurView alloc] init];
        _contentView.layer.masksToBounds = YES;
        _contentView.layer.cornerRadius = 5;
        _contentView.blurView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        
        [_contentView addSubview:self.normalButton];
        [_contentView addSubview:self.topButton];
        [_contentView addSubview:self.bottomButton];
        [_contentView addSubview:self.colorPickerView];
        [_contentView addSubview:self.titleLabel];
        
        [self.normalButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_offset(10);
            make.width.mas_equalTo(40 + ddp_isPad() * 20);
        }];
        
        [self.topButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.normalButton);
            make.top.equalTo(self.normalButton.mas_bottom).mas_offset(-2);
            make.size.equalTo(self.normalButton);
        }];
        
        [self.bottomButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.normalButton);
            make.top.equalTo(self.topButton.mas_bottom).mas_offset(-2);
            make.bottom.mas_offset(-10);
            make.size.equalTo(self.topButton);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.normalButton.mas_right).mas_equalTo(10);
            make.top.mas_equalTo(10 + ddp_isPad() * 20);
            make.right.mas_offset(-10);
        }];
        
        [self.colorPickerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(ddp_isPad() * 20);
            make.right.bottom.mas_offset(-10);
            make.left.equalTo(self.bottomButton.mas_right).mas_equalTo(10 + ddp_isPad() * 20);
            make.width.mas_equalTo(self.width * 0.5);
        }];
        
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (NKOColorPickerView *)colorPickerView {
    if (_colorPickerView == nil) {
        @weakify(self)
        _colorPickerView = [[NKOColorPickerView alloc] initWithFrame:CGRectMake(0, 0, self.width - 20, self.height - 50) color:nil andDidChangeColorBlock:nil];
        
        _colorPickerView.color = [DDPCacheManager shareCacheManager].sendDanmakuColor;
        [_colorPickerView setDidChangeColorBlock:^(UIColor *color) {
            @strongify(self)
            if (!self) return;
            
            //将浮点的rgb规整
            CGFloat r,g,b = 0;
            [color getRed:&r green:&g blue:&b alpha:nil];
            r = (int)(r * 255) / 255.0;
            g = (int)(g * 255) / 255.0;
            b = (int)(b * 255) / 255.0;
            
            color = [UIColor colorWithRed:r green:g blue:b alpha:1];
            
            [DDPCacheManager shareCacheManager].sendDanmakuColor = color;
            self.titleLabel.textColor = color;
            
            if (self.selectedCallback) {
                self.selectedCallback(color, [DDPCacheManager shareCacheManager].sendDanmakuMode);
            }
        }];
        
        if (ddp_isPad() == NO) {
            UIView *aView = [_colorPickerView valueForKey:@"crossHairs"];
            aView.size = CGSizeMake(26, 26);
            aView.layer.cornerRadius = 13;
        }
    }
    return _colorPickerView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        @weakify(self)
        [_bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            [self dismiss];
        }]];
        _bgView.backgroundColor = DDPRGBAColor(0, 0, 0, DEFAULT_BLACK_ALPHA);
        [self addSubview:_bgView];
    }
    return _bgView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.text = @"_(:3」∠)_ 测试弹幕";
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [DDPCacheManager shareCacheManager].sendDanmakuColor;
        [_titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    }
    return _titleLabel;
}

- (UIButton *)resetButton {
    if (_resetButton == nil) {
        _resetButton = [[UIButton alloc] init];
        [_resetButton setImage:[UIImage imageNamed:@"player_reset"] forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(touchResetButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_resetButton];
    }
    return _resetButton;
}

- (UIButton *)normalButton {
    if (_normalButton == nil) {
        _normalButton = [[UIButton alloc] init];
        _normalButton.adjustsImageWhenHighlighted = NO;
        _normalButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        _normalButton.titleLabel.numberOfLines = 0;
        [_normalButton setBackgroundImage:[self buttonBgImgWithFlag:YES index:0] forState:UIControlStateSelected];
        [_normalButton setBackgroundImage:[self buttonBgImgWithFlag:NO index:0] forState:UIControlStateNormal];
        [_normalButton setTitle:@"滚\n动" forState:UIControlStateNormal];
        [_normalButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
        [_normalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_normalButton addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _normalButton;
}

- (UIButton *)topButton {
    if (_topButton == nil) {
        _topButton = [[UIButton alloc] init];
        _topButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        _topButton.titleLabel.numberOfLines = 0;
        _topButton.adjustsImageWhenHighlighted = NO;
        [_topButton setBackgroundImage:[self buttonBgImgWithFlag:YES index:1] forState:UIControlStateSelected];
        [_topButton setBackgroundImage:[self buttonBgImgWithFlag:NO index:1] forState:UIControlStateNormal];
        [_topButton setTitle:@"顶\n部" forState:UIControlStateNormal];
        [_topButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
        [_topButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_topButton addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topButton;
}

- (UIButton *)bottomButton {
    if (_bottomButton == nil) {
        _bottomButton = [[UIButton alloc] init];
        _bottomButton.adjustsImageWhenHighlighted = NO;
        _bottomButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        _bottomButton.titleLabel.numberOfLines = 0;
        [_bottomButton setBackgroundImage:[self buttonBgImgWithFlag:YES index:2] forState:UIControlStateSelected];
        [_bottomButton setBackgroundImage:[self buttonBgImgWithFlag:NO index:2] forState:UIControlStateNormal];
        [_bottomButton setTitle:@"底\n部" forState:UIControlStateNormal];
        [_bottomButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
        [_bottomButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_bottomButton addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomButton;
}

@end
