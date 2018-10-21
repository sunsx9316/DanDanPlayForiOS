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



@end
