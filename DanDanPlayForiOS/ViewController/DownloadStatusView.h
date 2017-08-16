//
//  DownloadStatusView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/11.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DownloadStatusView : UIView
@property (assign, nonatomic, readonly, getter=isShow) BOOL show;

- (void)show;
- (void)dismiss;
- (void)showAnimate;
@end
