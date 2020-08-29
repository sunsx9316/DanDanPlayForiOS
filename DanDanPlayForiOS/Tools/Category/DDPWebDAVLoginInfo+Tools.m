//
//  DDPWebDAVLoginInfo+Tools.m
//  DDPlay
//
//  Created by JimHuang on 2020/6/7.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPWebDAVLoginInfo+Tools.h"

@implementation DDPWebDAVLoginInfo (Tools)

- (NSString *)itemHostName {
    return self.url.host;
}

- (NSString *)itemPasword {
    return self.userPassword;
}

- (NSString *)itemUserName {
    return self.userName;
}

@end
