//
//  DDPBangumiQueueIntroCollection.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseCollection.h"
#import "DDPBangumiQueueIntro.h"

@interface DDPBangumiQueueIntroCollection : DDPBaseCollection<DDPBangumiQueueIntro *>
@property (assign, nonatomic) BOOL hasMore;
@property (strong, nonatomic) NSArray <DDPBangumiQueueIntro *>*unwatchedBangumiList;
@end
