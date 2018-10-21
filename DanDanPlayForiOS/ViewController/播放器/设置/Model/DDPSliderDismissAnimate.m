//
//  DDPSliderDismissAnimate.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPSliderDismissAnimate.h"

@implementation DDPSliderDismissAnimate

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    let fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    let containerView = transitionContext.containerView;
    [containerView addSubview:fromVC.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:9 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromVC.view.left = containerView.width;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        if (self.didFinishAnimateCallBack) {
            self.didFinishAnimateCallBack(finished);
        }
    }];
}

@end
