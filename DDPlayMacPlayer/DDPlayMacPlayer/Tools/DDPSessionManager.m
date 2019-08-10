//
//  DDPSessionManager.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/7/28.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPSessionManager.h"

@interface DDPSessionManager ()
@property (strong, nonatomic) NSHashTable *observers;
@end

@implementation DDPSessionManager

+ (DDPSessionManager *)sharedManager {
    static dispatch_once_t onceToken;
    static DDPSessionManager *_manager;
    dispatch_once(&onceToken, ^{
        _manager = [[DDPSessionManager alloc] init];
    });
    return _manager;
}

- (void)addObserver:(id<DDPSessionManagerObserver>)observer {
    if ([self.observers containsObject:observer] == NO) {
        [self.observers addObject:observer];
    }
}

- (void)removeObserver:(id<DDPSessionManagerObserver>)observer {
    if ([self.observers containsObject:observer]) {
        [self.observers removeObject:observer];
    }
}

- (void)sendMessage:(DDPMessageModel *)message {
    NSAssert(message.name.length > 0 && message.parameter != nil, @"消息参数有误");
    
    NSError *err = nil;
    let path = [NSString stringWithFormat:@"dandanplay://%@", message.name];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:path] options:NSWorkspaceLaunchDefault configuration:message.parameter error:&err];
    if (err) {
        JHLog(@"发送消息出错 %@", err);
    }
}

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    let components = [[NSURLComponents alloc] initWithString:urlString];
    let model = [[DDPMessageModel alloc] initWithComponents:components];
    
    for (id<DDPSessionManagerObserver>obj in [self.observers copy]) {
        if ([obj respondsToSelector:@selector(dispatchManager:didReceiveMessage:)]) {
            [obj dispatchManager:self didReceiveMessage:model];
        }
    }
}


#pragma mark - 懒加载
- (NSHashTable *)observers {
    if (_observers == nil) {
        _observers = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory | NSPointerFunctionsObjectPointerPersonality capacity:0];
    }
    return _observers;
}

@end
