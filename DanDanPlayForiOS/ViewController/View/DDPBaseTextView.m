//
//  DDPBaseTextView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/7/21.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPBaseTextView.h"

@implementation DDPBaseTextView

- (instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer {
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Private Method
- (void)setup {
    self.backgroundColor = [UIColor ddp_backgroundColor];
    self.textColor = [UIColor blackColor];
    self.tintColor = [UIColor ddp_mainColor];
}

@end
