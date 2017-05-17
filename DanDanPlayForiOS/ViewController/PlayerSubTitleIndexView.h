//
//  PlayerSubTitleIndexView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerSubTitleIndexView : UIView
@property (nonatomic, assign) int currentVideoSubTitleIndex;
@property (nonatomic, strong) NSArray *videoSubTitlesNames;
@property (nonatomic, strong) NSArray *videoSubTitlesIndexes;
@property (copy, nonatomic) void(^selectedIndexCallBack)(int);
@property (copy, nonatomic) void(^didTapEmptyViewCallBack)();
- (void)show;
- (void)dismiss;
@end
