//
//  QRScanerViewController.h
//  TJSecurity
//
//  Created by JimHuang on 2017/7/14.
//  Copyright © 2017年 convoy. All rights reserved.
//

#import "JHBaseViewController.h"

@interface QRScanerViewController : JHBaseViewController
@property (copy, nonatomic) void(^linkSuccessCallBack)(JHLinkInfo *info);
@end
