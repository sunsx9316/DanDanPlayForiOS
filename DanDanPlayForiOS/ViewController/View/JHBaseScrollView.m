//
//  JHBaseScrollView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBaseScrollView.h"

@implementation JHBaseScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

@end
