//
//  AppDelegate.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/27.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "AppDelegate.h"
#import <DDPShare/DDPShare.h>
#import "DDPDanmakuManager.h"

@implementation AppDelegate

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(handleAppleEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[DDPDanmakuManager shared] syncSetting];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
//    [[DDPMessageManager sharedManager] sendMessage:[DDPExitMessage new]];
}

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    id<DDPMessageProtocol>message = [[NSURL URLWithString:urlString] makeMessage];
    [[DDPMessageManager sharedManager] receiveMessage:message];
}

@end
