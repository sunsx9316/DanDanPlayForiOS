//
//  DDPDMHYSearchCollection.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseCollection.h"
#import "DDPDMHYSearch.h"

@interface DDPDMHYSearchCollection : DDPBaseCollection<DDPDMHYSearch *>
@property (assign, nonatomic) BOOL hasMore;
@end
