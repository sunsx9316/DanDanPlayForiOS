//
//  DDPPlayerSelectedIndexView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/1.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DDPPlayerSelectedIndexView;
@protocol DDPPlayerSelectedIndexViewDelegate <NSObject>
@optional
- (void)selectedIndexView:(DDPPlayerSelectedIndexView *)view didSelectedIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath * _Nullable)selectedIndexPathForIndexView;
- (void)selectedIndexViewDidTapEmptyView;

@end

@protocol DDPPlayerSelectedIndexViewDataSource <NSObject>
- (NSInteger)indexView:(DDPPlayerSelectedIndexView *)view numbeOfRowInSection:(NSInteger)section;
@optional

- (NSInteger)numbeOfSectionInIndexView:(DDPPlayerSelectedIndexView *)view;
- (NSString * _Nullable)indexView:(DDPPlayerSelectedIndexView *)view titleAtIndexPath:(NSIndexPath *)indexPath;
- (NSString * _Nullable)emptyTitleInIndexView:(DDPPlayerSelectedIndexView *)view;
- (NSString * _Nullable)emptyDescriptionInIndexView:(DDPPlayerSelectedIndexView *)view;

@end

@interface DDPPlayerSelectedIndexView : UIView
@property (weak, nonatomic) id<DDPPlayerSelectedIndexViewDelegate>  _Nullable delegate;
@property (weak, nonatomic) id<DDPPlayerSelectedIndexViewDataSource> _Nullable dataSource;

@property (nonatomic, copy, nullable) UIVisualEffect *effect;
@property (strong, nonatomic) UIColor *contentViewBgColor;
@property (strong, nonatomic) UIColor *textColor;

- (void)show;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
