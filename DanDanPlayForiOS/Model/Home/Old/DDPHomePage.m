//
//  HomePageModel.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 16/10/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "DDPHomePage.h"

@implementation DDPHomePage

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"banners" : @"Banner.BannerPage",
             @"bangumis" : @"Bangumi.BangumiOfDay",
             @"todayFeaturedModel" : @"Featured"
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"banners" : [DDPHomeBanner class],
             @"bangumis" : [DDPHomeBangumiCollection class]
             };
}

@end
