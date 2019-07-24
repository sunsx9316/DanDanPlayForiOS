//
//  UIApplication+DDPTools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/7/22.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "UIApplication+DDPTools.h"

@implementation UIApplication (DDPTools)

- (UIWindow *)ddp_mainWindow {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    UIWindowScene *windowScene = (UIWindowScene *)[UIApplication sharedApplication].connectedScenes.anyObject;
    if (windowScene != nil) {
        UIWindow *aWindow = windowScene.windows.firstObject;
        return aWindow;
    }
#endif
    
    return [UIApplication sharedApplication].delegate.window;
}

- (NSString *)appDisplayName {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

@end
