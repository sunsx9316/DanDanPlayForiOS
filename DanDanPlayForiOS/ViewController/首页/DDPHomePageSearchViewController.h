//
//  DDPHomePageSearchViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

@interface DDPHomePageSearchViewController : DDPBaseViewController
@property (strong, nonatomic) DDPDMHYSearchConfig *config;

- (void)downloadVideoWithMagnet:(NSString *)magnet;
@end
