//
//  JHBiliBiliSearch.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHBiliBiliSearch : JHBase
//data分为两种 番剧和普通视频 用isBangumi属性区分

/**
 *  视频aid
 */
@property (assign, nonatomic) NSUInteger aid;
/**
 *  是否为番剧
 */
@property (assign, nonatomic, getter=isBangumi) BOOL bangumi;

/**
 *  desc 番剧/视频 描述
 name 番剧/视频 标题
 identity 番剧id
 */

@end
