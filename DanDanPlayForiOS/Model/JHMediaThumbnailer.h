//
//  JHMediaThumbnailer.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <MobileVLCKit/MobileVLCKit.h>

typedef void(^ParseCompletionAction)(UIImage *image);

@interface JHMediaThumbnailer : VLCMediaThumbnailer
@property (copy, nonatomic) ParseCompletionAction parseCompletionCallBack;
- (instancetype)initWithMedia:(VLCMedia *)media 
                        block:(ParseCompletionAction)block;
@end
