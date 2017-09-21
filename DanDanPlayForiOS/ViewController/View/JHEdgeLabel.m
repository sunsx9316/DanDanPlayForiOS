//
//  JHEdgeLabel.m
//  BreastDoctor
//
//  Created by JimHuang on 17/3/26.
//  Copyright © 2017年 Convoy. All rights reserved.
//

#import "JHEdgeLabel.h"

@implementation JHEdgeLabel

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    size.width += self.inset.width;
    size.height += self.inset.height;
    return size;
}

@end
