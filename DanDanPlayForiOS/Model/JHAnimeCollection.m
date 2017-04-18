//
//  JHAnimeCollection.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHAnimeCollection.h"

@implementation JHAnimeCollection

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super modelCustomPropertyMapper]];
    dic[@"hasMore"] = @"HasMore";
    return dic;
}

@end
