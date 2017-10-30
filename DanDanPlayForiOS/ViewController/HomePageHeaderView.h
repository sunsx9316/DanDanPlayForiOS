//
//  HomePageHeaderView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BANNER_HEIGHT 180
#define BANNER_BUTTON_HEIGHT 40
#define MENU_VIEW_HEIGHT 44
#define HOME_PAGE_HEADER_HEIGHT (BANNER_HEIGHT - MENU_VIEW_HEIGHT + BANNER_BUTTON_HEIGHT + 20)

@interface HomePageHeaderView : UIView
@property (strong, nonatomic) NSArray <JHBannerPage *>*dataSource;
@property (strong, nonatomic) UIButton *attionButton;
@property (strong, nonatomic) UIButton *searchButton;
@property (copy, nonatomic) void(^didSelctedModelCallBack)(JHBannerPage *model);
@end
