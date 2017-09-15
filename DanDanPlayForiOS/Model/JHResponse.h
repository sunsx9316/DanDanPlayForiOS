//
//  JHResponse.h
//  BaseProject
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

CG_INLINE NSError *jh_parameterNoCompletionError() {
    return [[NSError alloc] initWithDomain:@"参数不完整" code:10000 userInfo:nil];
};

CG_INLINE NSError *jh_creatDownloadTaskFailError() {
    return [[NSError alloc] initWithDomain:@"任务创建失败" code:10001 userInfo:nil];
};

@interface JHResponse : JHBase
@property (strong, nonatomic) id responseObject;
@property (strong, nonatomic) NSError *error;
- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error;
@end
