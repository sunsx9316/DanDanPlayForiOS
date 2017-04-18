//
//  JHResponse.h
//  BaseProject
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

CG_INLINE NSError *parameterNoCompletionError() {
    return [[NSError alloc] initWithDomain:@"参数不完整" code:10000 userInfo:nil];
};

@interface JHResponse : JHBase
@property (strong, nonatomic) id responseObject;
@property (strong, nonatomic) NSError *error;
- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error;
@end
