//
//  DDPPlayerSendDanmakuViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/27.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerSendDanmakuViewController.h"
#import "DDPPlayerSendDanmakuConfigView.h"
#import <YYKeyboardManager/YYKeyboardManager.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "DDPBaseTextView.h"

@interface DDPPlayerSendDanmakuViewController ()<YYKeyboardObserver, UITextViewDelegate>
@property (strong, nonatomic) UIButton *pickColorButton;
@property (strong, nonatomic) DDPBaseTextView *textView;
@end

@implementation DDPPlayerSendDanmakuViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发送弹幕";
    [[YYKeyboardManager defaultManager] addObserver:self];
    [[DDPCacheManager shareCacheManager] addObserver:self forKeyPath:@"sendDanmakuColor" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10, 10));
    }];
    
    [self.pickColorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-20);
        make.bottom.mas_equalTo(-15);
    }];
    
    [self setPickColorButtonShadowWithColor:[DDPCacheManager shareCacheManager].sendDanmakuColor];
    
    [self.textView becomeFirstResponder];
}

- (void)dealloc {
    [[YYKeyboardManager defaultManager] removeObserver:self];
    [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:@"sendDanmakuColor"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sendDanmakuColor"]) {
        UIColor *color = change[NSKeyValueChangeNewKey];
        self.pickColorButton.tintColor = color;
        [self setPickColorButtonShadowWithColor:color];
    }
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    if (transition.toVisible) {
        float offset = transition.toFrame.size.height;
        [self.pickColorButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-offset - 10);
        }];
        
        self.textView.contentInset = UIEdgeInsetsMake(0, 0, offset, 0);
        
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
    else {
        [self.pickColorButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_offset(-20);
        }];
        
        self.textView.contentInset = UIEdgeInsetsZero;
        
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (textView.text.length && self.sendDanmakuCallBack) {
            self.sendDanmakuCallBack([DDPCacheManager shareCacheManager].sendDanmakuColor, [DDPCacheManager shareCacheManager].sendDanmakuMode, textView.text);
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        return NO;
    }
    return YES;
}

#pragma mark - 私有方法
- (void)touchPickColorButton:(UIButton *)sender {
    [self.view endEditing:YES];
    DDPPlayerSendDanmakuConfigView *view = [[DDPPlayerSendDanmakuConfigView alloc] init];
    [view show];
    [self.textView endEditing:YES];
}

- (void)setPickColorButtonShadowWithColor:(UIColor *)color {
    if (color.brightness > 0.5) {
        self.pickColorButton.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
        self.pickColorButton.imageView.layer.shadowOpacity = 0.8;
    }
    else {
        self.pickColorButton.imageView.layer.shadowOpacity = 0;
    }
}

#pragma mark - 懒加载
- (DDPBaseTextView *)textView {
    if (_textView == nil) {
        _textView = [[DDPBaseTextView alloc] init];
        let attText = [[NSAttributedString alloc] initWithString:@"吐个槽~" attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont]}];
        _textView.attributedPlaceholder = attText;
        _textView.font = [UIFont ddp_normalSizeFont];
        _textView.returnKeyType = UIReturnKeySend;
        _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        _textView.delegate = self;
        _textView.alwaysBounceVertical = YES;
        [self.view addSubview:_textView];
    }
    return _textView;
}

- (UIButton *)pickColorButton {
    if (_pickColorButton == nil) {
        _pickColorButton = [[UIButton alloc] init];
        [_pickColorButton setImage:[[UIImage imageNamed:@"player_pick_color"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [_pickColorButton setBackgroundImage:[UIImage imageNamed:@"comment_down_load_hud"] forState:UIControlStateNormal];
        [_pickColorButton addTarget:self action:@selector(touchPickColorButton:) forControlEvents:UIControlEventTouchUpInside];
        _pickColorButton.tintColor = [DDPCacheManager shareCacheManager].sendDanmakuColor;
        _pickColorButton.imageView.layer.shadowRadius = 3;
        _pickColorButton.imageView.layer.masksToBounds = NO;
        _pickColorButton.imageView.layer.shadowOffset = CGSizeZero;
        [self.view addSubview:_pickColorButton];
    }
    return _pickColorButton;
}

@end
