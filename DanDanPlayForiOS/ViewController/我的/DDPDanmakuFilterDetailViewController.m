//
//  DDPDanmakuFilterDetailViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDanmakuFilterDetailViewController.h"
#import <IQKeyboardManager.h>
#import <YYKeyboardManager.h>
#import "DDPEdgeButton.h"
#import "DDPEdgeTextField.h"
#import "Masonry+DDPTools.h"
#import "DDPBaseTextView.h"

@interface DDPDanmakuFilterDetailViewController ()<YYKeyboardObserver, UITextViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) DDPEdgeTextField *nameTextField;
@property (strong, nonatomic) DDPBaseTextView *textView;
@end

@implementation DDPDanmakuFilterDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].enable = NO;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [IQKeyboardManager sharedManager].enable = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.textView becomeFirstResponder];
}

- (void)dealloc {
    [[YYKeyboardManager defaultManager] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configRightItem];
    [[YYKeyboardManager defaultManager] addObserver:self];
    
    if (self.model == nil) {
        self.model = [[DDPFilter alloc] init];
        self.model.enable = YES;
        self.model.identity = [NSDate date].hash;
        self.navigationItem.title = @"新增屏蔽规则";
    }
    else {
        self.navigationItem.title = @"编辑屏蔽规则";
    }
    
    [self.nameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.leading.equalTo(self.view.ddp_safeLeading).mas_offset(10);;
        make.trailing.equalTo(self.view.ddp_safeTrailing).mas_offset(-10);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameTextField.mas_bottom).mas_offset(10);
        make.leading.trailing.equalTo(self.nameTextField);
        make.bottom.equalTo(self.view.ddp_safeBottom).mas_offset(-10);
    }];
}

#pragma mark - YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    LOG_DEBUG(DDPLogModuleMine, @"键盘参数 toVisible: %d fromVisible: %d", transition.toVisible, transition.fromVisible);
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
        return [self saveFilter];
    }
    return YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [self saveFilter];
}

#pragma mark - 私有方法
- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"正则" configAction:^(UIButton *aButton) {
        @weakify(self)
        [aButton addBlockForControlEvents:UIControlEventTouchUpInside block:^(UIButton * _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            self.model.isRegex = !self.model.isRegex;
            sender.selected = self.model.isRegex;
            if (self.addFilterCallback && self.textView.text.length) {
                self.addFilterCallback(self.model);
            }
        }];
        
        [aButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [aButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        aButton.selected = self.model.isRegex;
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (BOOL)saveFilter {
    if (self.textView.text.length == 0) {
        [self.view showWithText:@"请输入屏蔽内容！"];
        return NO;
    }
    
    self.model.content = self.textView.text;
    self.model.name = self.nameTextField.text.length ? self.nameTextField.text : FILTER_DEFAULT_NAME;
    if (self.addFilterCallback) {
        self.addFilterCallback(self.model);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    return YES;
}

#pragma mark - 懒加载
- (DDPEdgeTextField *)nameTextField {
    if (_nameTextField == nil) {
        _nameTextField = [[DDPEdgeTextField alloc] init];
        _nameTextField.font = [UIFont ddp_normalSizeFont];
        _nameTextField.placeholder = @"请输入规则名称~";
        _nameTextField.borderInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _nameTextField.inset = CGSizeMake(0, 16);
        _nameTextField.backgroundColor = DDPRGBColor(240, 240, 240);
        _nameTextField.text = _model.name.length ? _model.name : FILTER_DEFAULT_NAME;
        [_nameTextField setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [_nameTextField setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        if (_model.identity > 0) {
            //自己创建的才允许改名字
            _nameTextField.userInteractionEnabled = YES;
            _nameTextField.textColor = [UIColor blackColor];
        }
        else {
            _nameTextField.userInteractionEnabled = NO;
            _nameTextField.textColor = [UIColor lightGrayColor];
        }
        
        _nameTextField.returnKeyType = UIReturnKeyDone;
        _nameTextField.delegate = self;
        
        [self.view addSubview:_nameTextField];
    }
    return _nameTextField;
}

- (DDPBaseTextView *)textView {
    if (_textView == nil) {
        _textView = [[DDPBaseTextView alloc] init];
        _textView.font = [UIFont ddp_normalSizeFont];
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"请输入屏蔽内容" attributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont]}];
        _textView.attributedPlaceholder = str;
        _textView.text = self.model.content;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.delegate = self;
        _textView.alwaysBounceVertical = YES;
        _textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        [self.view addSubview:_textView];
    }
    return _textView;
}

@end
