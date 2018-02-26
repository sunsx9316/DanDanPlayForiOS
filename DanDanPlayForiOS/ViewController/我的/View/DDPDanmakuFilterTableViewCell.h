//
//  DDPDanmakuFilterTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPDanmakuFilterTableViewCell : UITableViewCell
@property (strong, nonatomic) DDPFilter *model;
@property (copy, nonatomic) void(^touchRegexButtonCallBack)(DDPFilter *aModel);
@property (copy, nonatomic) void(^touchEnableButtonCallBack)(DDPFilter *aModel);
@end
