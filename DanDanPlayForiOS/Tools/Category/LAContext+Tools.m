//
//  LAContext+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LAContext+Tools.h"

@implementation LAContext (Tools)

- (NSString *)biometryTypeStringValue {
    if (@available(iOS 11.0, *)) {
        return self.biometryType == LABiometryTypeTouchID ? @"TouchID" : @"FaceID";
    }
    
    return @"TouchID";
}

@end
