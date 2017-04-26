//
//  PlayerListView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/23.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerListView : UIView
@property (copy, nonatomic) void(^didSelectedModelCallBack)(VideoModel *model);
@end
