//
//  NSView+DDPTools.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/27.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "NSView+DDPTools.h"

@implementation NSView (DDPTools)

+ (instancetype)loadFromNib {
    NSArray *arr = nil;
    if ([[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil topLevelObjects:&arr]) {
        for (NSView *view in arr) {
            if ([view isKindOfClass:self]) {
                return view;
            }
        }
    };
    return nil;
}

@end
