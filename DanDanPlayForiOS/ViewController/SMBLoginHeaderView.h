//
//  SMBLoginHeaderView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMBLoginHeaderView : UITableViewHeaderFooterView
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *addButton;
@property (copy, nonatomic) void(^touchAddButtonCallback)();
@end
