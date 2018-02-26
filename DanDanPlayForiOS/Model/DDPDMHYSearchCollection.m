//
//  DDPDMHYSearchCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDMHYSearchCollection.h"

@implementation DDPDMHYSearchCollection

+ (Class)entityClass {
    return [DDPDMHYSearch class];
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"collection" : @"Resources",
             @"hasMore" : @"HasMore"};
}

@end
