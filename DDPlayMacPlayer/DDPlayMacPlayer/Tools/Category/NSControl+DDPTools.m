//
//  NSControl+DDPTools.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/29.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "NSControl+DDPTools.h"

@implementation NSControl (DDPTools)

- (void)addTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
}

@end
