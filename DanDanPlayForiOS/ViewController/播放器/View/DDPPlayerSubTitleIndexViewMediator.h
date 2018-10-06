//
//  DDPPlayerSubTitleIndexViewMediator.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/3.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "DDPPlayerSelectedIndexView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPPlayerSubTitleIndexViewMediator : DDPBase<DDPPlayerSelectedIndexViewDelegate, DDPPlayerSelectedIndexViewDataSource>

@property (weak, nonatomic) DDPMediaPlayer *player;

@property (copy, nonatomic) void(^didTapSubTitleEmptyViewCallBack)(void);

@end

NS_ASSUME_NONNULL_END
