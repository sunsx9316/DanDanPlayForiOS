//
//  DDPHomeBangumi.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseCollection.h"

@interface DDPHomeBangumi : DDPBaseCollection
/**
 identity -> AnimeId
 *  name 名称
 *  @"collection" : [JHBangumiGroup class]
 */
@property (strong, nonatomic) NSString *keyword;
@property (strong, nonatomic) NSURL *imageURL;
@property (assign, nonatomic) BOOL isFavorite;
@end
