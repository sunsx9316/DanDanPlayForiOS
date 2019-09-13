//
//  DDPPlayView.h
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/9/13.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDPPlayView : NSView
@property (copy, nonatomic) void(^keyDownCallBack)(NSEvent *event);
@end

NS_ASSUME_NONNULL_END
