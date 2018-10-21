//
//  DDPPlayerInterfaceHolderView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPPlayerInterfaceHolderView : UIView
@property (copy, nonatomic) void(^touchViewCallBack)(void);
@end
