//
//  JHPlayHistory.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHPlayHistory : JHBaseCollection
/*
 identity -> AnimeId
 name -> AnimeTitle
 collection -> Episodes
 */

@property (strong, nonatomic) NSURL *imageUrl;
@property (assign, nonatomic) BOOL isFavorite;
@property (copy, nonatomic) NSString *searchKeyword;
#pragma mark - 自定义属性
@property (assign, nonatomic) BOOL isOnAir;
@end
