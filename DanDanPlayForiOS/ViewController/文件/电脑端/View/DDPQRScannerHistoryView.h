//
//  DDPQRScannerHistoryView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/1/27.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPQRScannerHistoryView : UIView
@property (copy, nonatomic) void(^selectedInfoCallBack)(DDPLinkInfo *info);

- (void)show;
- (void)dismiss;
@end
