//
//  DDPSearchCollection.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseCollection.h"
#import "DDPSearch.h"

@interface DDPSearchCollection : DDPBaseCollection<DDPSearch *>

/**
 返回包含节目信息的列表，当结果集过大时，hasMore属性为true，这时客户端应该提示用户填写更详细的信息以缩小搜索范围。
 */
@property (assign, nonatomic) BOOL hasMore;
@end
