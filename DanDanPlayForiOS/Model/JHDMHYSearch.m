//
//  JHDMHYSearch.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHDMHYSearch.h"

@implementation JHDMHYSearch

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
