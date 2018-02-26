//
//  DDPQRScannerViewController.h
//  TJSecurity
//
//  Created by JimHuang on 2017/7/14.
//  Copyright © 2017年 convoy. All rights reserved.
//

#import "DDPBaseViewController.h"

@interface DDPQRScannerViewController : DDPBaseViewController
@property (copy, nonatomic) void(^linkSuccessCallBack)(DDPLinkInfo *info);
@end
