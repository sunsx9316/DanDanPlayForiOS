//
//  JHBangumiQueueIntroCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBangumiQueueIntroCollection.h"

@implementation JHBangumiQueueIntroCollection

+ (Class)entityClass {
    return [JHBangumiQueueIntro class];
}

+ (NSString *)collectionKey {
    return @"BangumiList";
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    NSMutableDictionary *dic = [super modelCustomPropertyMapper].mutableCopy;
    dic[@"hasMore"] = @"HasMore";
    return dic;
}

@end
