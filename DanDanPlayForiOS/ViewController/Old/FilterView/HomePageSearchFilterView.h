//
//  HomePageSearchFilterView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FILTER_VIEW_HEIGHT 44

@class HomePageSearchFilterView, WMMenuView;
@protocol HomePageSearchFilterViewDataSource<NSObject>

- (NSInteger)numberOfSection;

- (NSInteger)numberOfItemAtSection:(NSInteger)section;
- (NSString *)itemTitleAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol HomePageSearchFilterViewDelegate<NSObject>
@optional
- (void)pageSearchFilterView:(HomePageSearchFilterView *)view
  didSelectedItemAtIndexPath:(NSIndexPath *)indexPath
                       title:(NSString *)title;

- (NSInteger)defaultSelectedItemAtSection:(NSInteger)section;
- (CGFloat)widthAtSection:(NSInteger)section;
@end

@interface HomePageSearchFilterView : UIView
//@property (strong, nonatomic, readonly) WMMenuView *menuView;
@property (weak, nonatomic) id<HomePageSearchFilterViewDataSource>dataSource;
@property (weak, nonatomic) id<HomePageSearchFilterViewDelegate>delegate;
//- (NSString *)titleInSection:(NSInteger)section;
- (NSInteger)selectedItemIndexAtSection:(NSInteger)section;

//- (NSString *)selectedTitleAtIndexPath:(NSIndexPath *)indexPath;
//- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
//             updateSectionTitle:(BOOL)updateSectionTitle;
- (void)reloadData;
@end
