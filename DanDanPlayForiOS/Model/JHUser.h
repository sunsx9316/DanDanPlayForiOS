//
//  JHUser.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/18.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBase.h"

@interface JHUser : JHBase
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) NSURL *icoImgURL;
@end
