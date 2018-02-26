//
//  DDPEmailListView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDPEmailListView : UIView
@property (copy, nonatomic) NSString *inputString;
@property (strong, nonatomic, readonly) UITableView *tableView;
- (NSString *)adviseEmailWithInputString:(NSString *)str;
@property (copy, nonatomic) void(^didSelectedRowCallBack)(NSString *email);
@end
