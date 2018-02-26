//
//  HomePageModel.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 16/10/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
// 主页模型

#import "DDPBaseCollection.h"
#import "DDPDMHYParse.h"
#import "DDPHomeBanner.h"
#import "DDPHomeFeatured.h"
#import "DDPHomeBangumiSubtitleGroup.h"
#import "DDPHomeBangumiCollection.h"

@interface DDPHomePage : DDPBase
@property (strong, nonatomic) NSArray <DDPHomeBanner *>*banners;
@property (strong, nonatomic) NSArray <DDPHomeBangumiCollection *>*bangumis;
@property (strong, nonatomic) DDPHomeFeatured *todayFeaturedModel;
@end
