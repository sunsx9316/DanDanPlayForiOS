//
//  DDPBiliBiliBangumiCollection.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseCollection.h"
#import "DDPBiliBiliBangumi.h"

@interface DDPBiliBiliBangumiCollection : DDPBaseCollection<DDPBiliBiliBangumi *>
/**
 *  name 标题
    collection 分集
    desc 简介
 */

/**
 *  封面
 */
@property (strong, nonatomic) NSURL *imgURL;
@end
