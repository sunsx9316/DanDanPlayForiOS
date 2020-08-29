//
//  DDPWebDAVHasnCache.h
//  DDPlay
//
//  Created by JimHuang on 2020/6/9.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDPWebDAVHasnCache : NSObject

@property (copy, nonatomic) NSString *key;
@property (copy, nonatomic) NSString *md5;
@property (strong, nonatomic) NSDate *date;

@end
