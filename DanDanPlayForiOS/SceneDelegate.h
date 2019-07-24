//
//  SceneDelegate.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/7/21.
//  Copyright © 2019 jim. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000

API_AVAILABLE(ios(13.0)) @interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;

@end

#endif
