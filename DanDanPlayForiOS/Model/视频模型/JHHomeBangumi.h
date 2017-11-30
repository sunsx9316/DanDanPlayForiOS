//
//  JHHomeBangumi.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  番剧实体

#import "JHBaseCollection.h"
#import "JHHomeBangumiSubtitleGroup.h"

@interface JHHomeBangumi : JHBaseCollection
/**
 identity -> AnimeId
 *  name 名称
 *  @"collection" : [JHHomeBangumiSubtitleGroup class]
 */
@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) NSURL *imageURL;
@property (assign, nonatomic) BOOL isFavorite;
@end
