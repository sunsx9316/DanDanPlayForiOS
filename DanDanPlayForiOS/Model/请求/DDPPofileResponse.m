//
//  DDPPofileResponse.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPofileResponse.h"

@interface DDPPofileResponse()

@property (assign, nonatomic) BOOL updateScreenNameSuccess;
@property (assign, nonatomic) BOOL updatePasswordSuccess;

@end

@implementation DDPPofileResponse

- (instancetype)initWithResponseObject:(id)responseObject error:(NSError *)error {
    if (self = [super init]) {
        self.responseObject = responseObject;
        
        if (error) {
            self.error = error;
        }
        else {
            [self yy_modelSetWithJSON:responseObject];
            
            if (self.updatePasswordSuccess == false) {
                self.error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-999 userInfo:@{NSLocalizedDescriptionKey : @"更改用户密码失败"}];
            }
            else if (self.updateScreenNameSuccess == false) {
                self.error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:-999 userInfo:@{NSLocalizedDescriptionKey : @"更新用户名称失败"}];
            }
        }
    }
    
    return self;
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"updatePasswordSuccess" : @"UpdatePasswordSuccess",
             @"updateScreenNameSuccess" : @"UpdateScreenNameSuccess"};
}

@end
