//
//  DDPDMHYParse.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDMHYParse.h"

@implementation DDPDMHYParse

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"keywords" : @"Keyword",
             @"identity" : @"TeamId"};
}

- (NSString *)keyword {
    if (_keywords.count == 0) return nil;
    
    NSMutableString *str = [[NSMutableString alloc] init];
    [_keywords enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [str appendFormat:@"%@ ", obj];
    }];
    
    //移除最后的空格
    if (str.length > 1) {
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    }
    
    return str;
}

@end
