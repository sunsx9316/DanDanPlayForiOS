//
//  DDPHomePageBannerView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/5.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

#if DDPAPPTYPEISMAC
#define HOME_BANNER_VIEW_HEIGHT 320
#else
#define HOME_BANNER_VIEW_HEIGHT 180
#endif

NS_ASSUME_NONNULL_BEGIN

@interface DDPHomePageBannerView : UIView
@property (strong, nonatomic) NSArray <DDPNewBanner *>*models;
@end

NS_ASSUME_NONNULL_END
