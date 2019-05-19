//
//  DDPLinkFileTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPLinkFileTableViewCell.h"
#import "DDPMediaPlayer.h"
#import "DDPVideoModel+Tools.h"

@implementation DDPLinkFileTableViewCell
{
    DDPLinkFile *_model;
}

- (void)setModel:(DDPLinkFile *)model {
    _model = model;
    
    DDPLibrary *library = _model.library;
    
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", library.animeTitle.length ? library.animeTitle : @"", library.episodeTitle.length ? library.episodeTitle : @""];
    let imgURL = ddp_linkImageURL([DDPCacheManager shareCacheManager].linkInfo.selectedIpAdress, library.playId);
    [self.bgImgView ddp_setImageWithURL:imgURL];
//    DDPVideoCache *cache = [[DDPCacheManager shareCacheManager] episodeLinkCacheWithVideoModel:_model.videoModel];
    NSInteger time = _model.videoModel.lastPlayTime;
    if (time > 0) {
        self.lastPlayTimeButton.hidden = NO;
        [self.lastPlayTimeButton setTitle:[NSString stringWithFormat:@"• %@", ddp_mediaFormatterTime(time)] forState:UIControlStateNormal];
    }
    else {
        self.lastPlayTimeButton.hidden = YES;
    }
}

@end
