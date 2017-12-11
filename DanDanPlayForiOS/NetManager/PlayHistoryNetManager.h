//
//  PlayHistoryNetManager.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseNetManager.h"
#import "JHBangumiQueueIntroCollection.h"

@interface PlayHistoryNetManager : BaseNetManager
+ (NSURLSessionDataTask *)playHistoryWithUser:(JHUser *)user
                         completionHandler:(void(^)(JHBangumiQueueIntroCollection *responseObject, NSError *error))completionHandler;
@end
