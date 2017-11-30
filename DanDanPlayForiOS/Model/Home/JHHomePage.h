//
//  HomePageModel.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 16/10/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
// 主页模型

#import "JHBaseCollection.h"
#import "JHDMHYParse.h"
#import "JHHomeBanner.h"
#import "JHHomeFeatured.h"
#import "JHHomeBangumiSubtitleGroup.h"
#import "JHHomeBangumiCollection.h"

@interface JHHomePage : JHBase
@property (strong, nonatomic) NSArray <JHHomeBanner *>*banners;
@property (strong, nonatomic) NSArray <JHHomeBangumiCollection *>*bangumis;
@property (strong, nonatomic) JHHomeFeatured *todayFeaturedModel;
@end
