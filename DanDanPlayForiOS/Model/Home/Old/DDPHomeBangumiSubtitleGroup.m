//
//  DDPHomeBangumiSubtitleGroup.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHomeBangumiSubtitleGroup.h"

@implementation DDPHomeBangumiSubtitleGroup
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"name":@"GroupName",
             @"link":@"SearchUrl"};
}

- (DDPDMHYParse *)parseModel {
    NSURL *url = [NSURL URLWithString:self.link];
    //url解码
    NSString *query = [url.query stringByURLDecode];
    NSArray <NSString *>*parameter = [query componentsSeparatedByString:@"&"];
    //获取keyword
    __block NSString *keyword = nil;
    [parameter enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj rangeOfString:@"keyword"].location != NSNotFound) {
            keyword = obj;
            *stop = YES;
        }
    }];
    
    //获取team_id
    NSString *value = [keyword componentsSeparatedByString:@"="].lastObject;
    NSMutableArray <NSString *>*values = [value componentsSeparatedByString:@"+"].mutableCopy;
    __block NSString *teamId = nil;
    [values enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj rangeOfString:@"team_id"].location != NSNotFound) {
            teamId = [obj componentsSeparatedByString:@":"].lastObject;
            [values removeObject:obj];
        }
    }];
    
    DDPDMHYParse *model = [[DDPDMHYParse alloc] init];
    model.keywords = values;
    model.identity = teamId.integerValue;
    model.name = self.name;
    model.link = self.link;
    return model;
}
@end
