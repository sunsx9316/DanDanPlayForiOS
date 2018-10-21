//
//  DDPNewBanner.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPNewBanner : DDPBase

/*
 name -> title 标题 ,
 desc -> description 子标题、描述 ,
 */

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSURL *imageUrl;

@end

NS_ASSUME_NONNULL_END
