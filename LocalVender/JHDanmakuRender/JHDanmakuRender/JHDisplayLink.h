//
//  JHDisplayLink.h
//  JHDanmakuRender
//
//  Created by JimHuang on 16/2/22.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import <CoreVideo/CoreVideo.h>
#import <Foundation/Foundation.h>

@protocol JHDisplayLinkDelegate <NSObject>
- (void)displayLinkDidCallback;
@end

@interface JHDisplayLink : NSObject
@property (nonatomic, weak) id <JHDisplayLinkDelegate> delegate;

- (void)start;
- (void)pause;

@end
