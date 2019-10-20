//
//  DDPPlayerAudioChannelViewMediator.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/3.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPPlayerAudioChannelViewMediator.h"
#import "DDPMediaPlayer.h"

@implementation DDPPlayerAudioChannelViewMediator
#pragma mark - DDPPlayerSelectedIndexViewDataSource

- (NSInteger)indexView:(DDPPlayerSelectedIndexView *)view numbeOfRowInSection:(NSInteger)section {
    return self.player.audioChannelTitles.count;
}

- (NSString * _Nullable)indexView:(DDPPlayerSelectedIndexView *)view titleAtIndexPath:(NSIndexPath *)indexPath {
    NSString *name = [NSString stringWithFormat:@"%@", self.player.audioChannelTitles[indexPath.row]];
    return name;
}

- (NSString * _Nullable)emptyTitleInIndexView:(DDPPlayerSelectedIndexView *)view {
    return @"并没有能切换的音轨( ・_ゝ・)";
}

#pragma mark - DDPPlayerSelectedIndexViewDelegate
- (void)selectedIndexView:(DDPPlayerSelectedIndexView *)view didSelectedIndexPath:(nonnull NSIndexPath *)indexPath {
    NSNumber *index = self.player.audioChannelIndexs[indexPath.row];
    self.player.currentAudioChannelIndex = index.intValue;
}

- (NSIndexPath *)selectedIndexPathForIndexView {
    NSInteger index = [self.player.audioChannelIndexs indexOfObject:@(self.player.currentAudioChannelIndex)];
    if (index == NSNotFound) {
        return nil;
    }
    return [NSIndexPath indexPathForRow:index inSection:0];
}

@end
