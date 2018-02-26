//
//  DDPEdgeButton.m
//  BreastDoctor
//
//  Created by JimHuang on 17/4/4.
//  Copyright © 2017年 Convoy. All rights reserved.
//

#import "DDPEdgeButton.h"

@implementation DDPEdgeButton

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width += self.inset.width;
    size.height += self.inset.height;
    return size;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    CGRect rect = self.bounds;
//    rect = (CGRect){rect.origin.x - _actionInsets.left, rect.origin.y - _actionInsets.top, rect.size.width + _actionInsets.right, rect.size.height + _actionInsets.bottom};
//    if (CGRectContainsPoint(rect, point)) {
//        return self;
//    }
//
//    return [super hitTest:point withEvent:event];
//}



@end
