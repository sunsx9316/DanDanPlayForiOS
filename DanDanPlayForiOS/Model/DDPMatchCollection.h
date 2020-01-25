//
//  DDPMatchCollection.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseCollection.h"
#import "DDPMatch.h"

@interface DDPMatchCollection : DDPBaseCollection<DDPMatch *>

/**
 是否已精确关联到某个弹幕库
 */
@property (assign, nonatomic) BOOL isMatched;
@end
