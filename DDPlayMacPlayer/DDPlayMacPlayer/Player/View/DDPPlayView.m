//
//  DDPPlayView.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/9/13.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPPlayView.h"

@implementation DDPPlayView

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)keyDown:(NSEvent *)event {
    if (self.keyDownCallBack) {
        self.keyDownCallBack(event);
    }
}

@end
