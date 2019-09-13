//
//  UIApplication+DDPTools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/7/22.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (DDPTools)

@property (strong, nonatomic, readonly) UIWindow *ddp_mainWindow;
@property (strong, nonatomic, readonly) NSString *appDisplayName;
@property (strong, nonatomic, readonly) UINavigationController * _Nullable topNavigationController;
@end

NS_ASSUME_NONNULL_END
