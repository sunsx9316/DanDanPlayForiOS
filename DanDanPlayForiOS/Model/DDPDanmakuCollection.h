//
//  DDPDanmakuCollection.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseCollection.h"
#import "DDPDanmaku.h"

@interface DDPDanmakuCollection : DDPBaseCollection<DDPDanmaku *>

#pragma mark - 自定义属性
@property (strong, nonatomic) NSDate *saveTime;
@end
