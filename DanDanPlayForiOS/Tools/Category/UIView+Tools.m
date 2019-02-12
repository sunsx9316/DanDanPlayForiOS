//
//  UIView+Tools.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "UIView+Tools.h"

@implementation UIView (Tools)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleInstanceMethod:@selector(ddp_pointInside:withEvent:) with:@selector(pointInside:withEvent:)];
    });
}

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

- (void)setRequiredContentVerticalResistancePriority {
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
}

- (void)setRequiredContentHorizontalResistancePriority {
    [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
}

+ (UINib *)loadNib {
    return [UINib nibWithNibName:[self className] bundle:nil];
}

+ (instancetype)fromXib {
    let nib = [self loadNib];
    return [nib instantiateWithOwner:nil options:nil].firstObject;
}

- (UIEdgeInsets)ddp_hitTestSlop {
    NSValue *value = objc_getAssociatedObject(self, _cmd);
    return [value UIEdgeInsetsValue];
}

- (void)setDdp_hitTestSlop:(UIEdgeInsets)ddp_hitTestSlop {
    objc_setAssociatedObject(self, @selector(ddp_hitTestSlop), [NSValue valueWithUIEdgeInsets:ddp_hitTestSlop], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ddp_pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    UIEdgeInsets slop = self.ddp_hitTestSlop;
    if (UIEdgeInsetsEqualToEdgeInsets(slop, UIEdgeInsetsZero)) {
        return [self ddp_pointInside:point withEvent:event];
    }
    else {
        return CGRectContainsPoint(UIEdgeInsetsInsetRect(self.bounds, slop), point);
    }
}

- (void)ddp_showViewWithHolderView:(UIView *)holderView
                        completion:(void(^)(BOOL finished))completion{

    if (self.superview == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.alpha = 0;
    holderView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:8 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1;
        holderView.transform = CGAffineTransformIdentity;
    } completion:completion];
}

- (void)ddp_dismissViewWithCompletion:(void (^)(BOOL))completion {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (completion) {
            completion(finished);
        }
    }];
}

@end
