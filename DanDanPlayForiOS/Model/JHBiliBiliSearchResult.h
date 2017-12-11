//
//  JHBiliBiliSearchResult.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"
#import "JHBiliBiliSearchBangumi.h"
#import "JHBiliBiliSearchVideo.h"

@interface JHBiliBiliSearchResult : JHBase
@property (strong, nonatomic) NSArray <JHBiliBiliSearchBangumi *>*bangumi;
@property (strong, nonatomic) NSArray <JHBiliBiliSearchVideo *>*video;
@end
