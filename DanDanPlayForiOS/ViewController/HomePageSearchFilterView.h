//
//  HomePageSearchFilterView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FILTER_VIEW_HEIGHT 44

@class HomePageSearchFilterView;
@protocol HomePageSearchFilterViewDataSource<NSObject>
- (NSInteger)numberOfItem;
- (NSString *)itemTitleAtSection:(NSInteger)section;

- (NSInteger)numberOfSubItemAtSection:(NSInteger)index;
- (NSString *)subItemTitleAtIndex:(NSInteger)index section:(NSInteger)section;
@end

@protocol HomePageSearchFilterViewDelegate<NSObject>
@optional
- (void)pageSearchFilterView:(HomePageSearchFilterView *)view didSelectedSubItemAtIndex:(NSInteger)index
                   section:(NSInteger)section
                       title:(NSString *)title;
@end

@interface HomePageSearchFilterView : UIView
@property (weak, nonatomic) id<HomePageSearchFilterViewDataSource>dataSource;
@property (weak, nonatomic) id<HomePageSearchFilterViewDelegate>delegate;
- (NSString *)titleInSection:(NSInteger)section;
- (NSInteger)selectedItemIndexAtSection:(NSInteger)section;
- (void)selectedSubItemAtIndex:(NSInteger)index section:(NSInteger)section;
- (void)reloadData;
@end
