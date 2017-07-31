//
//  UIView+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIView+Tools.h"

@implementation UIView (Tools)

- (void)addMotionEffectWithMaxOffset:(CGFloat)offset {
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    effectX.maximumRelativeValue = @(offset);
    effectX.minimumRelativeValue = @(-offset);
    
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    effectY.maximumRelativeValue = @(offset);
    effectY.minimumRelativeValue = @(-offset);
    
    UIMotionEffectGroup *group = [[UIMotionEffectGroup alloc] init];
    group.motionEffects = @[effectX, effectY];
    [self addMotionEffect:group];
}

- (void)removeMotionEffect {
    NSArray *effects = [self motionEffects];
    for (UIMotionEffect *effect in effects) {
        [self removeMotionEffect:effect];
    }
}

@end
