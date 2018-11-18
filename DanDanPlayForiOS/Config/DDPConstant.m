//
//  DDPConstant.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/11/18.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPConstant.h"

DDPProductionType DDPProductionTypeTVSeries = @"tvseries";
DDPProductionType DDPProductionTypeTVSpecial = @"tvspecial";
DDPProductionType DDPProductionTypeOVA = @"ova";
DDPProductionType DDPProductionTypeMovie = @"movie";
DDPProductionType DDPProductionTypeMusicVideo = @"musicvideo";
DDPProductionType DDPProductionTypeWeb = @"web";
DDPProductionType DDPProductionTypeOther = @"other";
DDPProductionType DDPProductionTypeMusicJPMovie = @"jpmovie";
DDPProductionType DDPProductionTypeMusicJPDrama = @"jpdrama";
DDPProductionType DDPProductionTypeMusicUnknown = @"unknown";

#if DDPAPPTYPE == 1
DDPAppType ddp_appType = DDPAppTypeReview;
#else
DDPAppType ddp_appType = DDPAppTypeDefault;
#endif

@implementation DDPConstant

@end
