//
//  UIViewController+FullScreenPopGesture.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 AICoin. All rights reserved.
//

#import "UIViewController+FullScreenPopGesture.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import <RTRootNavigationController/RTRootNavigationController.h>

//默认响应手势返回边距
#define DDP_DEFAULT_INTERACTIVE_EDGE 40

@implementation UIViewController (FullScreenPopGesture)

- (void)setDdp_fullScreenPopGestureEnabled:(BOOL)fullScreenPopGestureEnable {
    self.ddp_interactivePopMaxAllowedInitialDistanceToLeftEdge = DDP_DEFAULT_INTERACTIVE_EDGE * !fullScreenPopGestureEnable;
}

- (BOOL)ddp_fullScreenPopGestureEnabled {
    return self.ddp_interactivePopMaxAllowedInitialDistanceToLeftEdge == 0;
}

- (RTRootNavigationController *)ddp_navigationController {
    return self.rt_navigationController;
}

- (BOOL)ddp_navigationBarHidden {
    return self.fd_prefersNavigationBarHidden;
}

- (void)setDdp_navigationBarHidden:(BOOL)navigationBarHidden {
    self.fd_prefersNavigationBarHidden = navigationBarHidden;
}

- (void)setDdp_interactivePopMaxAllowedInitialDistanceToLeftEdge:(CGFloat)edge {
    UIViewController *vc = self;
    vc.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge = edge;
}

- (CGFloat)ddp_interactivePopMaxAllowedInitialDistanceToLeftEdge {
    UIViewController *vc = self;
    return vc.fd_interactivePopMaxAllowedInitialDistanceToLeftEdge;
}

@end
