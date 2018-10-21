//
//  DDPNewBangumiIntroCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewBangumiIntroCollection.h"
#import "DDPNewBangumiIntro.h"

@implementation DDPNewBangumiIntroCollection

+ (NSString *)collectionKey {
    return @"bangumiList";
}

+ (Class)entityClass {
    return [DDPNewBangumiIntro class];
}

@end
