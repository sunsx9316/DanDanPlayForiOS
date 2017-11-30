//
//  JHHomeBangumi.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHHomeBangumi.h"

@implementation JHHomeBangumi
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"imageURL":@"ImageUrl",
             @"keyword":@"Keyword",
             @"name":@"Name",
             @"collection":@"Groups.Group",
             @"isFavorite": @"IsFavorite",
             @"identity" : @"AnimeId"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"collection" : [JHHomeBangumiSubtitleGroup class]};
}



@end
