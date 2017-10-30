//
//  HomePageSearchFilterModel.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomePageSearchFilterModel : NSObject
@property (copy, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray <NSString *>*subItems;
@end
