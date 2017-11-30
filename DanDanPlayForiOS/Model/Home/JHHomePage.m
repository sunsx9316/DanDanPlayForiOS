//
//  HomePageModel.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 16/10/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "JHHomePage.h"

@implementation JHHomePage

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"banners" : @"Banner.BannerPage",
             @"bangumis" : @"Bangumi.BangumiOfDay",
             @"todayFeaturedModel" : @"Featured"
             };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"banners" : [JHHomeBanner class],
             @"bangumis" : [JHHomeBangumiCollection class]
             };
}

@end
