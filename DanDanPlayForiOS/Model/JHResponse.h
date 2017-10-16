//
//  JHResponse.h
//  BaseProject
//
//  Created by JimHuang on 17/2/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

CG_INLINE NSError *jh_parameterNoCompletionError() {
    return [[NSError alloc] initWithDomain:@"参数不完整" code:10000 userInfo:@{NSLocalizedDescriptionKey : @"参数不完整"}];
};

CG_INLINE NSError *jh_creatDownloadTaskFailError() {
    return [[NSError alloc] initWithDomain:@"任务创建失败" code:10001 userInfo:@{NSLocalizedDescriptionKey : @"任务创建失败"}];
};

#define DANDANPLAY_LOGIN_FAILE 10002

#define DANDANPLAY_REGISTER_FAILE 10003

#define DANDANPLAY_BINDING_FAILE 10004

#define DANDANPLAY_UPDATE_USER_NAME_FAILE 10005


@interface JHResponse : JHBase
@property (strong, nonatomic) id responseObject;
@property (strong, nonatomic) NSError *error;
- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error;
@end
