//
//  LAContext+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <LocalAuthentication/LocalAuthentication.h>

@interface LAContext (Tools)
@property (copy, nonatomic, readonly) NSString *biometryTypeStringValue;
@end
