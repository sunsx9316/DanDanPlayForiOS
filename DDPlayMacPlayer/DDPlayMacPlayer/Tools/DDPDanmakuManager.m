//
//  DDPDanmakuManager.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/9/7.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPDanmakuManager.h"
#import <JHDanmakuRender/JHDanmakuRender.h>
#import <DDPShare/DDPBridgeDanmaku.h>
#import <DDPShare/DDPBridgeFilter.h>
#import <DDPShare/DDPDanmakuSettingMessage.h>
#import <DDPShare/DDPShare.h>
#import <YYModel/YYModel.h>
#import "JHBaseDanmaku+DDPTools.h"
#import "NSColor+DDPTools.h"

@interface DDPDanmakuManager ()<DDPMessageManagerObserver>
@property (strong, nonatomic) DDPDanmakuSettingMessage *setting;
@end

@implementation DDPDanmakuManager

+ (DDPDanmakuManager *)shared {
    static dispatch_once_t onceToken;
    static DDPDanmakuManager* _manager;
    dispatch_once(&onceToken, ^{
        _manager = [[DDPDanmakuManager alloc] init];
    });
    return _manager;
}

#pragma mark - Life Cycle

- (instancetype)init {
    self = [super init];
    if (self) {
        [[DDPMessageManager sharedManager] addObserver:self];
    }
    return self;
}

#pragma mark - Public
- (JHBaseDanmaku *)converDanmaku:(DDPBridgeDanmaku *)danmaku {
    if (danmaku == nil) return nil;
    
    return [self converDanmakus:@[danmaku] filter:NO].allValues.firstObject.firstObject;
}

- (NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *>*>*)converDanmakus:(NSArray <DDPBridgeDanmaku *>*)danmakus filter:(BOOL)filter {
    
    NSMutableDictionary <NSNumber *, NSMutableArray <JHBaseDanmaku *> *> *dic = [NSMutableDictionary dictionary];
    let font = self.setting.danmakuFont;
    JHDanmakuEffectStyle shadowStyle = (JHDanmakuEffectStyle)self.setting.danmakuEffectStyle.integerValue;
    let danmakuFilters = self.setting.filters;
    
    [danmakus enumerateObjectsUsingBlock:^(DDPBridgeDanmaku * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger time = obj.time;
        NSMutableArray *danmakus = dic[@(time)];
        if (danmakus == nil) {
            danmakus = [NSMutableArray array];
            dic[@(time)] = danmakus;
        }
        
        JHBaseDanmaku *tempDanmaku = nil;
        if (obj.mode == DDPDanmakuModeBottom || obj.mode == DDPDanmakuModeTop) {
            
            tempDanmaku = [[JHFloatDanmaku alloc] initWithFont:font text:obj.message textColor:[NSColor colorWithRGB:obj.color] effectStyle:shadowStyle during:3 position:obj.mode == DDPDanmakuModeBottom ? JHFloatDanmakuPositionAtBottom : JHFloatDanmakuPositionAtTop];
        }
        else {
            CGFloat speed = 130 - obj.message.length * 2.5;
            
            if (speed < 50) {
                speed = 50;
            }
            
            speed += arc4random() % 20;
            tempDanmaku = [[JHScrollDanmaku alloc] initWithFont:font text:obj.message textColor:[NSColor colorWithRGB:obj.color] effectStyle:shadowStyle speed:speed direction:JHScrollDanmakuDirectionR2L];
        }
        tempDanmaku.appearTime = obj.time;
        if (filter) {
            tempDanmaku.filter = [self filterWithDanmakuContent:obj.message danmakuFilters:danmakuFilters];
        }
        
        [danmakus addObject:tempDanmaku];
    }];

    return dic;
}

#pragma mark - DDPMessageManagerObserver
- (void)dispatchManager:(DDPMessageManager *)manager didReceiveMessages:(NSArray <id<DDPMessageProtocol>>*)messages {
    for (id<DDPMessageProtocol>message in messages) {
        if ([message.messageType isEqualToString:DDPDanmakuSettingMessage.messageType]) {
            let dic = message.messageParameter;
            [self.setting yy_modelSetWithJSON:dic];
            
            DDPDanmakuSettingMessage *aNewSetting = [DDPDanmakuSettingMessage yy_modelWithJSON:dic];
            if (self.settingDidChangeCallBack) {
                self.settingDidChangeCallBack(aNewSetting);
            }
        }
    }
}

#pragma mark - Private

- (void)syncSetting {
    DDPDanmakuSettingMessage *message = [[DDPDanmakuSettingMessage alloc] init];
    [[DDPMessageManager sharedManager] sendMessage:message];
}

//过滤弹幕
- (BOOL)filterWithDanmakuContent:(NSString *)content danmakuFilters:(NSArray <DDPBridgeFilter *>*)danmakuFilters {
    for (DDPBridgeFilter *filter in danmakuFilters) {
        
        if (filter.enable == false) {
            continue;
        }
        
        //使用正则表达式
        if (filter.isRegex && filter.content.length > 0) {
            if ([self matchesWithString:content regex:filter.content options:NSRegularExpressionCaseInsensitive]) {
                return YES;
            }
        }
        else if ([content containsString:filter.content]){
            return YES;
        }
    }
    return NO;
}

- (BOOL)matchesWithString:(NSString *)str regex:(NSString *)regex options:(NSRegularExpressionOptions)options {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
    if (!pattern) return NO;
    return ([pattern numberOfMatchesInString:str options:0 range:NSMakeRange(0, str.length)] > 0);
}

#pragma mark - 懒加载
- (DDPDanmakuSettingMessage *)setting {
    if (_setting == nil) {
        _setting = [[DDPDanmakuSettingMessage alloc] init];
    }
    return _setting;
}

@end
