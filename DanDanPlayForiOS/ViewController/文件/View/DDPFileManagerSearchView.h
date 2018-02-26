//
//  DDPFileManagerSearchView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDPFileManagerSearchView;
@protocol DDPFileManagerSearchViewDelegate <NSObject>
@optional
- (void)searchView:(DDPFileManagerSearchView *)searchView didSelectedFile:(DDPFile *)file;

@end

@interface DDPFileManagerSearchView : UIView
@property (strong, nonatomic) DDPFile *file;
@property (weak, nonatomic) id<DDPFileManagerSearchViewDelegate> delegete;
@property (assign, nonatomic, getter=isShowing) BOOL showing;
- (void)show;
- (void)dismiss;
@end
