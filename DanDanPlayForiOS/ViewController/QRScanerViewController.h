//
//  QRScanerViewController.h
//  TJSecurity
//
//  Created by JimHuang on 2017/7/14.
//  Copyright © 2017年 convoy. All rights reserved.
//

#import "BaseViewController.h"

@interface QRScanerViewController : BaseViewController
@property (copy, nonatomic) void(^linkSuccessCallBack)(JHLinkInfo *info);
@end
