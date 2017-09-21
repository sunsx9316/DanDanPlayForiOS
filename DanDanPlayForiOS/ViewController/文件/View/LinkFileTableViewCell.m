//
//  LinkFileTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/14.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LinkFileTableViewCell.h"

@implementation LinkFileTableViewCell
{
    JHLibrary *_model;
}

- (void)setModel:(JHLibrary *)model {
    _model = model;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@", _model.animeTitle.length ? _model.animeTitle : @"", _model.episodeTitle.length ? _model.episodeTitle : @""];
    [self.bgImgView jh_setImageWithURL:jh_linkImageURL([CacheManager shareCacheManager].linkInfo.selectedIpAdress, _model.md5)];
}

@end
