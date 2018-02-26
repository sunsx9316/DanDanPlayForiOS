//
//  DDPHomeBangumiSubtitleGroup.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  番剧字幕组

#import "DDPBase.h"

@interface DDPHomeBangumiSubtitleGroup : DDPBase
/**
 *  name 名称
 */
@property (strong, nonatomic) NSString *link;
- (DDPDMHYParse *)parseModel;
@end
