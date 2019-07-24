//
//  HomePageHeaderTableViewCell.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseTableViewCell.h"
#define BANNER_HEIGHT 180
#define BANNER_BUTTON_HEIGHT 40
//#define MENU_VIEW_HEIGHT 44
#define HOME_PAGE_HEADER_HEIGHT (BANNER_HEIGHT + BANNER_BUTTON_HEIGHT + 20)

@interface HomePageHeaderTableViewCell : DDPBaseTableViewCell
@property (strong, nonatomic) NSArray <DDPNewBanner *>*dataSource;

@property (copy, nonatomic) void(^didSelctedModelCallBack)(DDPNewBanner *model);
@property (copy, nonatomic) void(^touchTimeLineButtonCallBack)(void);
@property (copy, nonatomic) void(^touchSearchButtonCallBack)(void);
@end
