//
//  FileManagerSearchView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FileManagerSearchView;
@protocol FileManagerSearchViewDelegate <NSObject>
@optional
- (void)searchView:(FileManagerSearchView *)searchView didSelectedFile:(JHFile *)file;

@end

@interface FileManagerSearchView : UIView
@property (weak, nonatomic) id<FileManagerSearchViewDelegate> delegete;
@property (assign, nonatomic, getter=isShowing) BOOL showing;
- (void)show;
- (void)dismiss;
@end
