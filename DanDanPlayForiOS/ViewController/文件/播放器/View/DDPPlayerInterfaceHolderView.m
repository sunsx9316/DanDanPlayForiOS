//
//  DDPPlayerInterfaceHolderView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerInterfaceHolderView.h"

@implementation DDPPlayerInterfaceHolderView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (self.touchViewCallBack) {
        self.touchViewCallBack();
    }
    
    if (view == self) {
        return nil;
    }
    return view;
}

@end
