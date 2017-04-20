//
//  JHSearchCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHSearchCollection.h"

@implementation JHSearchCollection

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"collection" : @"Animes", @"hasMore" : @"HasMore"};
}

@end
