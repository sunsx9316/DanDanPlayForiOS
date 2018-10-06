//
//  DDPBatchResponse.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPResponse.h"

@interface DDPBatchResponse : DDPResponse
@property (strong, nonatomic) NSURLSessionTask *task;
@end
