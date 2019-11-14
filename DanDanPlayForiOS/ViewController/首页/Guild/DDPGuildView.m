//
//  DDPGuildView.m
//  DDPlay_ToMac
//
//  Created by JimHuang on 2019/11/10.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPGuildView.h"

@interface DDPGuildView ()
@property (weak, nonatomic) IBOutlet UIButton *faqButton;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation DDPGuildView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.okButton setTitleColor:UIColor.ddp_mainColor forState:UIControlStateNormal];
    self.okButton.layer.cornerRadius = 5;
    self.okButton.layer.masksToBounds = YES;
}

- (IBAction)onTouchFAQButton:(UIButton *)sender {
    let path = [[NSBundle mainBundle] pathForResource:@"FAQ" ofType:@"html"];
    if (path) {
        [UIApplication.sharedApplication openURL:[NSURL fileURLWithPath:path] options:@{} completionHandler:nil];
    }
}

- (void)show {
    if (self.superview == nil) {
        NSAssert(NO, @"superview不存在");
        return;
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        DDPCacheManager.shareCacheManager.guildViewIsShow = YES;
        [self removeFromSuperview];
    }];
}

- (IBAction)onClickOKButton:(UIButton *)sender {
    [self dismiss];
}



@end
