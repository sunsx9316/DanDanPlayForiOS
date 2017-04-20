//
//  JHDanmakuCollection.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBaseCollection.h"
#import "JHDanmaku.h"

@interface JHDanmakuCollection : JHBaseCollection

#pragma mark - 自定义属性
@property (strong, nonatomic) NSDate *saveTime;
@end
