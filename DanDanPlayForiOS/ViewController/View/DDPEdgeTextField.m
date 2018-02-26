//
//  DDPEdgeTextField.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/11.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPEdgeTextField.h"

CG_INLINE CGRect ddp_CGRectInsets(CGRect rect, UIEdgeInsets insets) {
    return CGRectMake(rect.origin.x + insets.left, rect.origin.y + insets.top, rect.size.width - insets.right, rect.size.height - insets.bottom);
};

@implementation DDPEdgeTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    CGRect rect = [super textRectForBounds:bounds];
    return ddp_CGRectInsets(rect, _borderInsets);
}

- (CGRect)editingRectForBounds:(CGRect)bounds; {
    CGRect rect = [super editingRectForBounds:bounds];
    return ddp_CGRectInsets(rect, _borderInsets);
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    CGRect rect = [super placeholderRectForBounds:bounds];
    return ddp_CGRectInsets(rect, _borderInsets);
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width += self.inset.width;
    size.height += self.inset.height;
    return size;
}

@end
