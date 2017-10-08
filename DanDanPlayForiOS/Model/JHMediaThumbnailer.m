//
//  JHMediaThumbnailer.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHMediaThumbnailer.h"

@interface JHMediaThumbnailer ()<VLCMediaThumbnailerDelegate>

@end

@implementation JHMediaThumbnailer
- (instancetype)initWithMedia:(VLCMedia *)media
                        block:(ParseCompletionAction)block {
    if (self = [super init]) {
        self.media = media;
        self.delegate = self;
        self.libVLCinstance = [VLCLibrary sharedLibrary].instance;
        self.parseCompletionCallBack = block;
    }
    return self;
}

#pragma mark - VLCMediaThumbnailerDelegate
- (void)mediaThumbnailerDidTimeOut:(VLCMediaThumbnailer *)mediaThumbnailer {
    if (self.parseCompletionCallBack) {
        self.parseCompletionCallBack(nil);
    }
}

- (void)mediaThumbnailer:(VLCMediaThumbnailer *)mediaThumbnailer didFinishThumbnail:(CGImageRef)thumbnail {
    if (self.parseCompletionCallBack) {
        self.parseCompletionCallBack([[UIImage alloc] initWithCGImage:thumbnail]);
    }
}

@end
