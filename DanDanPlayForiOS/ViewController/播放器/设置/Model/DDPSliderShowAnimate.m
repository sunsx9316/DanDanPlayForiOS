//
//  DDPSliderShowAnimate.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPSliderShowAnimate.h"

@implementation DDPSliderShowAnimate

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    let toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if (toVC == nil) {
        return;
    }
    
    let containerView = transitionContext.containerView;
    
    let holdView = [[UIView alloc] init];
    [containerView addSubview:holdView];
    holdView.frame = containerView.bounds;
    @weakify(toVC)
    [holdView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
        @strongify(toVC)
        if (!toVC) {
            return;
        }
        
        [toVC dismissViewControllerAnimated:true completion:nil];
    }]];
    
    
    [containerView addSubview:toVC.view];
    let width = containerView.width * 0.5;
    toVC.view.frame = CGRectMake(containerView.width, 0, width, containerView.height);
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:9 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        toVC.view.left = containerView.width - width;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

@end
