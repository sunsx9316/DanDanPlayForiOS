//
//  JHFilterCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHFilterCollection.h"

@implementation JHFilterCollection

+ (Class)entityClass {
    return [JHFilter class];
}

+ (NSString *)collectionKey {
    return @"FilterItem";
}

@end
