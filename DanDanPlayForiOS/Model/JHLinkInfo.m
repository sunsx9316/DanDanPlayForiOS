//
//  JHLinkInfo.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/13.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHLinkInfo.h"

@implementation JHLinkInfo

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name" : @"machineName",
             @"ipAdress" : @"ip"};
}

@end
