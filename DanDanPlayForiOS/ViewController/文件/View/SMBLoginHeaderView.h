//
//  SMBLoginHeaderView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "TextHeaderView.h"

@interface SMBLoginHeaderView : TextHeaderView
@property (strong, nonatomic) UIButton *addButton;
@property (copy, nonatomic) void(^touchAddButtonCallback)(void);
@end
