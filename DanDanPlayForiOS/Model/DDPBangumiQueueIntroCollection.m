//
//  DDPBangumiQueueIntroCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBangumiQueueIntroCollection.h"

@implementation DDPBangumiQueueIntroCollection

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"unwatchedBangumiList" : @"UnwatchedBangumiList",
             @"collection" : @"BangumiList",
             @"hasMore" : @"HasMore"};
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"unwatchedBangumiList" : [DDPBangumiQueueIntro class], @"collection" : [DDPBangumiQueueIntro class]};
}

@end
