//
//  JHSMBInfo.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHSMBInfo.h"

@implementation JHSMBInfo

- (void)setHostName:(NSString *)hostName {
    _hostName = [hostName lowercaseString];
}

- (BOOL)isEqual:(JHSMBInfo *)object {
    if ([object isKindOfClass:[JHSMBInfo class]] == NO) {
        return NO;
    }
    
    if ([object.hostName isEqualToString:self.hostName] && [object.userName isEqualToString:self.userName] && [object.password isEqual:self.password]) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash {
    return self.hostName.hash | self.userName.hash | self.password.hash;
}

@end
