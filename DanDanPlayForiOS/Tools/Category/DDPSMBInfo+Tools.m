//
//  DDPSMBInfo+Tools.m
//  DDPlay
//
//  Created by JimHuang on 2020/6/7.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPSMBInfo+Tools.h"

@implementation DDPSMBInfo (Tools)

- (NSString *)itemHostName {
    if (self.hostName.length) {
        return self.hostName;
    }
    return self.ipAddress;
}

- (NSString *)itemPasword {
    return self.password;
}

- (NSString *)itemUserName {
    return self.userName;
}

@end
