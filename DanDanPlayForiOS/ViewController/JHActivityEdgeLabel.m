//
//  JHActivityEdgeLabel.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHActivityEdgeLabel.h"

@implementation JHActivityEdgeLabel

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)copy:(id)sender {
    [UIPasteboard generalPasteboard].string = self.text;
}

@end
