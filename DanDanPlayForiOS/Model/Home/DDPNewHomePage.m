//
//  DDPNewHomePage.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewHomePage.h"

@implementation DDPNewHomePage

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"banners" : [DDPNewBanner class],
             @"bangumiQueueIntroList" : [DDPNewBangumiQueueIntro class],
             @"shinBangumiList" : [DDPNewBangumiIntro class],
             @"bangumiSeasons" : [DDPNewBangumiSeason class],
             @"popularTorrents" : [DDPNewPopularTorrentItem class]
             };
}

@end
