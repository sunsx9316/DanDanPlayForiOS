//
//  JHDanmakuCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHDanmakuCollection.h"

@implementation JHDanmakuCollection

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"collection" : [JHDanmaku class]};
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"collection" : @"Comments"};
}

@end
