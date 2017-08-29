//
//  PlayerInterfaceHolderView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerInterfaceHolderView : UIView
@property (copy, nonatomic) void(^touchViewCallBack)();
@end
