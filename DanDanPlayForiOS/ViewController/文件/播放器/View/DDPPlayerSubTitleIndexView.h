//
//  DDPPlayerSubTitleIndexView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  字幕选择视图

#import <UIKit/UIKit.h>

@interface DDPPlayerSubTitleIndexView : UIView
@property (nonatomic, assign) int currentVideoSubTitleIndex;
@property (nonatomic, strong) NSArray *videoSubTitlesNames;
@property (nonatomic, strong) NSArray *videoSubTitlesIndexes;
@property (copy, nonatomic) void(^selectedIndexCallBack)(int);
@property (copy, nonatomic) void(^didTapEmptyViewCallBack)(void);
- (void)show;
- (void)dismiss;
@end
