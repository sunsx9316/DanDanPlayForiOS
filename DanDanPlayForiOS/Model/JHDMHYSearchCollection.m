//
//  JHDMHYSearchCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHDMHYSearchCollection.h"

@implementation JHDMHYSearchCollection

+ (Class)entityClass {
    return [JHDMHYSearch class];
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"collection" : @"Resources",
             @"hasMore" : @"HasMore"};
}

@end
