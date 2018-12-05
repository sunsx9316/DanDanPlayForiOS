//
//  DDPHomeBangumiIntroHeaderView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/6.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPTextHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPHomeBangumiIntroHeaderView : DDPTextHeaderView
@property (copy, nonatomic) void(^touchHeaderCallBack)(void);
@end

NS_ASSUME_NONNULL_END
