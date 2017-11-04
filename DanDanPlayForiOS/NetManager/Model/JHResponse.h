//
//  JHResponse.h
//  BaseProject
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHResponse : JHBase
@property (strong, nonatomic) id responseObject;
@property (strong, nonatomic) NSError *error;
- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error;
@end
