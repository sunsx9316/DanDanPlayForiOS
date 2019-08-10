//
//  DDPWindowController.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/27.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPWindowController.h"
#import "DDPPlayViewController.h"

@interface DDPWindowController ()

@end

@implementation DDPWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.contentViewController = [[DDPPlayViewController alloc] init];
}

@end
