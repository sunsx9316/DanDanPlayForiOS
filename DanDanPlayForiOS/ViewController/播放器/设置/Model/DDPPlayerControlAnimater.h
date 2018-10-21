//
//  DDPPlayerControlAnimater.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/9/23.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
typedef void(^DDPSliderFinishAnimateAction)(BOOL success);

NS_ASSUME_NONNULL_BEGIN

@interface DDPPlayerControlAnimater : DDPBase<UIViewControllerTransitioningDelegate>

@property (copy, nonatomic) DDPSliderFinishAnimateAction didFinishAnimateCallBack;

@end

NS_ASSUME_NONNULL_END
