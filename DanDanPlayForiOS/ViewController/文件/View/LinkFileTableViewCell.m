//
//  LinkFileTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LinkFileTableViewCell.h"
#import "JHMediaPlayer.h"

@implementation LinkFileTableViewCell
{
    JHLinkFile *_model;
}

- (void)setModel:(JHLinkFile *)model {
    _model = model;
    
    JHLibrary *library = _model.library;
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", library.animeTitle.length ? library.animeTitle : @"", library.episodeTitle.length ? library.episodeTitle : @""];
    [self.bgImgView jh_setImageWithURL:jh_linkImageURL([CacheManager shareCacheManager].linkInfo.selectedIpAdress, library.md5)];
    NSInteger time = [[CacheManager shareCacheManager] lastPlayTimeWithVideoModel:_model.videoModel];
    if (time >= 0) {
        self.lastPlayTimeButton.hidden = NO;
        [self.lastPlayTimeButton setTitle:[NSString stringWithFormat:@"• %@", jh_mediaFormatterTime(time)] forState:UIControlStateNormal];
    }
    else {
        self.lastPlayTimeButton.hidden = YES;
    }
}

@end
