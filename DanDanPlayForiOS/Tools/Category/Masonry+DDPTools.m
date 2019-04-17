//
//  Masonry+AICTools.h.m
//  AICoin
//
//  Created by JimHuang on 2018/11/9.
//  Copyright © 2018 AICoin. All rights reserved.
//

#import "Masonry+DDPTools.h"

@interface MASConstraintMaker ()
- (MASConstraint *)addConstraintWithAttributes:(MASAttribute)attrs;
@end

@implementation MASConstraintMaker (DDPTools)


- (MASConstraint *)directionEdges {
    if ([self respondsToSelector:@selector(addConstraintWithAttributes:)]) {
        return [self addConstraintWithAttributes:MASAttributeTop | MASAttributeLeading | MASAttributeTrailing | MASAttributeBottom];
    }
    return self.edges;
}



@end

@implementation UIView (DDPConstraint)

- (MASViewAttribute *)ddp_safeTop {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTop];
    }
    else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTop];
    }
}

- (MASViewAttribute *)ddp_safeBottom {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
    }
    else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeBottom];
    }
}

- (MASViewAttribute *)ddp_safeLeft {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeft];
    }
    else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeft];
    }
}

- (MASViewAttribute *)ddp_safeRight {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeRight];
    }
    else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeRight];
    }
}

- (MASViewAttribute *)ddp_safeLeading {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeLeading];
    }
    else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeLeading];
    }
}

- (MASViewAttribute *)ddp_safeTrailing {
    if (@available(iOS 11.0, *)) {
        return [[MASViewAttribute alloc] initWithView:self item:self.safeAreaLayoutGuide layoutAttribute:NSLayoutAttributeTrailing];
    }
    else {
        return [[MASViewAttribute alloc] initWithView:self layoutAttribute:NSLayoutAttributeTrailing];
    }
}

@end
