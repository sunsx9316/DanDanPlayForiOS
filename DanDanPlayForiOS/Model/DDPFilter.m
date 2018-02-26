//
//  DDPFilter.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFilter.h"

@implementation DDPFilter

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"isRegex" : @"IsRegex",
             @"name" : @"Name",
             @"content" : @"_text"
             };
}

- (NSUInteger)hash {
    if (self.identity == 0) {
        return self.name.hash;
    }
    
    if (self.name.length == 0) {
        return self.identity;
    }
    
    return self.identity | self.name.hash;
}

- (BOOL)isEqual:(DDPFilter *)object {
    if ([object isKindOfClass:self.class] == NO) {
        return NO;
    }
    
    if (self == object) {
        return YES;
    }
    
    return self.identity == object.identity && [self.name isEqualToString:object.name];
}

@end
