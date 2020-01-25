//
//  DDPBaseCollection.h
//  BreastDoctor
//
//  Created by JimHuang on 17/3/25.
//  Copyright © 2017年 Convoy. All rights reserved.
//

#import "DDPBase.h"

@interface DDPBaseCollection<T> : DDPBase
/// __kindof DDPBase
@property (strong, nonatomic) NSMutableArray <T>*collection;
+ (NSString *)collectionKey;
+ (Class)entityClass;
@end
