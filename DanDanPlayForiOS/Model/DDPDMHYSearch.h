//
//  DDPDMHYSearch.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  动漫花园搜索结果

#import "DDPBase.h"

@interface DDPDMHYSearch : DDPBase
/*
 name -> Title
*/


/**
 文件大小
 */
@property (copy, nonatomic) NSString *fileSize;

/**
 磁力链
 */
@property (copy, nonatomic) NSString *magnet;

/**
 详情网页
 */
@property (strong, nonatomic) NSURL *pageUrl;

/**
 发布日期 2017-09-06 20:11:00
 */
@property (copy, nonatomic) NSString *publishDate;

/**
 字幕组id
 */
@property (assign, nonatomic) NSUInteger subgroupId;

/**
 字幕组名称
 */
@property (copy, nonatomic) NSString *subgroupName;

/**
 类型id
 */
//@property (assign, nonatomic) DDPEpisodeType typeId;

/**
 类型名称
 */
@property (copy, nonatomic) NSString *typeName;
@end
