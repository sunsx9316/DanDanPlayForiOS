//
//  DDPDMHYSearch.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPDMHYSearch.h"

@implementation DDPDMHYSearch

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"fileSize" : @"FileSize",
             @"magnet" : @"Magnet",
             @"pageUrl" : @"PageUrl",
             @"publishDate" : @"PublishDate",
             @"subgroupId" : @"SubgroupId",
             @"subgroupName" : @"SubgroupName",
             @"name" : @"Title",
             @"typeId" : @"TypeId",
             @"typeName" : @"TypeName"};
}

@end
