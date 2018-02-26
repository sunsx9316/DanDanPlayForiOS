//
//  DDPBiliBiliSearchResult.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBase.h"
#import "DDPBiliBiliSearchBangumi.h"
#import "DDPBiliBiliSearchVideo.h"

@interface DDPBiliBiliSearchResult : DDPBase
@property (strong, nonatomic) NSArray <DDPBiliBiliSearchBangumi *>*bangumi;
@property (strong, nonatomic) NSArray <DDPBiliBiliSearchVideo *>*video;
@end
