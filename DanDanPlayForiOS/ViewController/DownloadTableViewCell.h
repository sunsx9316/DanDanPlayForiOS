//
//  DownloadTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadTableViewCell : UITableViewCell
@property (strong, nonatomic, readonly) TOSMBSessionDownloadTask *task;
- (void)setTask:(TOSMBSessionDownloadTask *)task animate:(BOOL)animate;
- (void)updateDataSourceWithAnimate:(BOOL)flag;
@end
