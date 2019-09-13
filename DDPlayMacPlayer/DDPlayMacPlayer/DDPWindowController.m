//
//  DDPWindowController.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/27.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPWindowController.h"
#import "DDPPlayViewController.h"
#import <Masonry/Masonry.h>

@interface DDPWindowController ()

@end

@implementation DDPWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.movableByWindowBackground = YES;
    self.contentViewController = [[DDPPlayViewController alloc] init];
}

@end
