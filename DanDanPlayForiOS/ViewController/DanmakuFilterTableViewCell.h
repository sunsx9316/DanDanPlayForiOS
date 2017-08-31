//
//  DanmakuFilterTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/31.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DanmakuFilterTableViewCell : UITableViewCell
@property (strong, nonatomic) JHFilter *model;
@property (copy, nonatomic) void(^touchRegexButtonCallBack)(JHFilter *aModel);
@property (copy, nonatomic) void(^touchEnableButtonCallBack)(JHFilter *aModel);
@end
