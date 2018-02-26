//
//  DDPFileManagerNavigationBar.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileManagerNavigationBar.h"

@implementation DDPFileManagerNavigationBar

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *aView = [super hitTest:point withEvent:event];
    if (aView == self || [self.subviews containsObject:aView]) {
        return nil;
    }
    return aView;
}

@end
