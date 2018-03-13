//
//  DDPDownloadTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDPDownloadTaskProtocol.h"

@interface DDPDownloadTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIView *progressView;

@property (assign, nonatomic) BOOL showHightlight;

@property (strong, nonatomic) id<DDPDownloadTaskProtocol> task;
@end
