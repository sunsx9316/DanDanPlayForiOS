//
//  DDPNewHomePageBangumiIntroCollectionViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDPNewHomePageBangumiIntroCollectionViewCell : UICollectionViewCell
@property (copy, nonatomic) void(^touchLikeButtonCallBack)(DDPNewBangumiIntro *model);
@property (copy, nonatomic) void(^attentionCallBack)(NSUInteger animateId);
@property (strong, nonatomic) DDPNewBangumiIntro *model;

@property (assign, nonatomic) CGSize itemSize;
@end

NS_ASSUME_NONNULL_END
