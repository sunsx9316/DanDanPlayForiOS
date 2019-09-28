//
//  DDPDanmakuManager.h
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/9/7.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class JHBaseDanmaku, DDPBridgeDanmaku, DDPDanmakuSettingMessage;

@interface DDPDanmakuManager : NSObject

@property (strong, nonatomic, readonly) DDPDanmakuSettingMessage *setting;

@property (strong, nonatomic, class, readonly) DDPDanmakuManager *shared;

@property (copy, nonatomic) void(^settingDidChangeCallBack)(DDPDanmakuSettingMessage *setting);

- (void)syncSetting;

- (NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*)converDanmakus:(NSArray <DDPBridgeDanmaku *>*)danmakus filter:(BOOL)filter;

- (JHBaseDanmaku *)converDanmaku:(DDPBridgeDanmaku *)danmaku;
@end

NS_ASSUME_NONNULL_END
