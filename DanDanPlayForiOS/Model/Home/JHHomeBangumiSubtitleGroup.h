//
//  JHHomeBangumiSubtitleGroup.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  番剧字幕组

#import "JHBase.h"

@interface JHHomeBangumiSubtitleGroup : JHBase
/**
 *  name 名称
 */
@property (strong, nonatomic) NSString *link;
- (JHDMHYParse *)parseModel;
@end
