//
//  DDPPlayerSubTitleIndexViewMediator.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/3.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPPlayerSubTitleIndexViewMediator.h"
#import "DDPMediaPlayer.h"

@implementation DDPPlayerSubTitleIndexViewMediator

#pragma mark - DDPPlayerSelectedIndexViewDataSource


- (NSInteger)numbeOfSectionInIndexView:(DDPPlayerSelectedIndexView *)view {
    if (self.player.subtitleTitles.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)indexView:(DDPPlayerSelectedIndexView *)view numbeOfRowInSection:(NSInteger)section {
    if (section == 0) {
        return self.player.subtitleTitles.count > 0;
    }
    return self.player.subtitleTitles.count;
}

- (NSString * _Nullable)indexView:(DDPPlayerSelectedIndexView *)view titleAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return @"选择字幕...";
    }
    
    NSString *name = [NSString stringWithFormat:@"%@", self.player.subtitleTitles[indexPath.row]];
    return name;
}

- (NSString * _Nullable)emptyTitleInIndexView:(DDPPlayerSelectedIndexView *)view {
    return @"字幕呢( ・_ゝ・)";
}

- (NSString * _Nullable)emptyDescriptionInIndexView:(DDPPlayerSelectedIndexView *)view {
    return @"点击选择";
}

#pragma mark - DDPPlayerSelectedIndexViewDelegate
- (void)selectedIndexView:(DDPPlayerSelectedIndexView *)view didSelectedIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self selectedIndexViewDidTapEmptyView];
    }
    else {
        NSNumber *index = self.player.subtitleIndexs[indexPath.row];
        self.player.currentSubtitleIndex = index.intValue;
    }
}

- (NSIndexPath *)selectedIndexPathForIndexView {
    NSInteger index = [self.player.subtitleIndexs indexOfObject:@(self.player.currentSubtitleIndex)];
    if (index == NSNotFound) {
        return nil;
    }
    return [NSIndexPath indexPathForRow:index inSection:1];
}

- (void)selectedIndexViewDidTapEmptyView {
    if (self.didTapSubTitleEmptyViewCallBack) {
        self.didTapSubTitleEmptyViewCallBack();
    }
}

@end
