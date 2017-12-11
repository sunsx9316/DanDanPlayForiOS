//
//  HomePageHeaderTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define BANNER_HEIGHT 180
#define BANNER_BUTTON_HEIGHT 40
//#define MENU_VIEW_HEIGHT 44
#define HOME_PAGE_HEADER_HEIGHT (BANNER_HEIGHT + BANNER_BUTTON_HEIGHT + 20)

@interface HomePageHeaderTableViewCell : UITableViewCell
@property (strong, nonatomic) NSArray <JHHomeBanner *>*dataSource;

@property (copy, nonatomic) void(^didSelctedModelCallBack)(JHHomeBanner *model);
@property (copy, nonatomic) void(^touchTimeLineButtonCallBack)(void);
@property (copy, nonatomic) void(^touchSearchButtonCallBack)(void);
@end
