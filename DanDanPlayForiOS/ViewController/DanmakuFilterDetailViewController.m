//
//  DanmakuFilterDetailViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DanmakuFilterDetailViewController.h"
#import <UITextView+Placeholder.h>
#import <IQKeyboardManager.h>
#import <YYKeyboardManager.h>
#import "JHEdgeButton.h"

@interface DanmakuFilterDetailViewController ()<YYKeyboardObserver, UITextViewDelegate>
@property (strong, nonatomic) UITextView *textView;
@end

@implementation DanmakuFilterDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)dealloc {
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRightItem];
    [[YYKeyboardManager defaultManager] addObserver:self];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (self.model == nil) {
        self.model = [[JHFilter alloc] init];
        self.model.enable = YES;
        self.model.identity = [NSDate date].hash;
        self.navigationItem.title = @"新增屏蔽规则";
    }
    else {
        self.navigationItem.title = @"编辑屏蔽规则";
    }
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    if (transition.toVisible) {
        float offset = transition.toFrame.size.height;
        
        
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            self.textView.contentInset = UIEdgeInsetsMake(0, 0, offset, 0);
        } completion:nil];
    }
    else {
        
        [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
            self.textView.contentInset = UIEdgeInsetsZero;
        } completion:nil];
    }
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if (self.textView.text.length == 0) {
            [MBProgressHUD showWithText:@"请输入屏蔽内容！"];
            return NO;
        }
        
        self.model.content = self.textView.text;
        if (self.addFilterCallback) {
            self.addFilterCallback(self.model);
        }
        [self.navigationController popViewControllerAnimated:YES];
        
        return NO;
    }
    return YES;
}

#pragma mark - 私有方法
- (void)configRightItem {
    JHEdgeButton *regexButton = [[JHEdgeButton alloc] init];
    regexButton.inset = CGSizeMake(10, 10);
    @weakify(self)
    [regexButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(UIButton * _Nonnull sender) {
        @strongify(self)
        if (!self) return;
        
        self.model.isRegex = !self.model.isRegex;
        sender.selected = self.model.isRegex;
        if (self.addFilterCallback) {
            self.addFilterCallback(self.model);
        }
    }];
    [regexButton setTitle:@"正则" forState:UIControlStateNormal];
    regexButton.titleLabel.font = NORMAL_SIZE_FONT;
    [regexButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [regexButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [regexButton sizeToFit];
    regexButton.selected = self.model.isRegex;
    UIBarButtonItem *regexItem = [[UIBarButtonItem alloc] initWithCustomView:regexButton];
    
    self.navigationItem.rightBarButtonItem = regexItem;
}

#pragma mark - 懒加载
- (UITextView *)textView {
    if (_textView == nil) {
        _textView = [[UITextView alloc] init];
        _textView.font = NORMAL_SIZE_FONT;
        _textView.placeholderLabel.font = NORMAL_SIZE_FONT;
        _textView.placeholder = @"请输入屏蔽内容";
        _textView.text = self.model.content;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.delegate = self;
        _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        _textView.alwaysBounceVertical = YES;
        [self.view addSubview:_textView];
    }
    return _textView;
}

@end
