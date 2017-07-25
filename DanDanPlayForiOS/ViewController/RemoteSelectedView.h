//
//  RemoteSelectedView.h
//  TJSecurity
//
//  Created by JimHuang on 2017/6/10.
//  Copyright © 2017年 convoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemoteSelectedView : UIView
@property (strong, nonatomic) NSArray <NSString *>*models;
@property (copy, nonatomic) void(^didSelctedRowWithTypeCallBack)(NSString *, NSUInteger);
- (void)show;
- (void)dismiss;
@end
