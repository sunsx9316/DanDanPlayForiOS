//
//  DDPPlayerControlAnimater.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPPlayerControlAnimater.h"
#import "DDPSliderShowAnimate.h"
#import "DDPSliderDismissAnimate.h"


@implementation DDPPlayerControlAnimater

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[DDPSliderShowAnimate alloc] init];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    let animater = [[DDPSliderDismissAnimate alloc] init];
    animater.didFinishAnimateCallBack = self.didFinishAnimateCallBack;
    return animater;
}

@end
