//
//  DDPMarqueeView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/1.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDPMarqueeView : UIView
@property (strong, nonatomic) UILabel *label;

- (void)startAnimate;
- (void)stopAnimate;

@end

NS_ASSUME_NONNULL_END
