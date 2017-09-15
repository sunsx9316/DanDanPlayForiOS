//
//  DownloadTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/3.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadTableViewCell : UITableViewCell
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *progressLabel;
@property (strong, nonatomic) UIView *progressView;

@property (strong, nonatomic) UILabel *titleBGLabel;
@property (strong, nonatomic) UILabel *progressBGLabel;

@property (strong, nonatomic) CALayer *progressLayer;

@property (strong, nonatomic, readonly) id task;
- (void)setTask:(id)task animate:(BOOL)animate;
- (void)updateDataSourceWithAnimate:(BOOL)flag;
@end
