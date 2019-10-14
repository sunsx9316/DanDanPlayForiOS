//
//  DDPPlayerListView.h
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/10/13.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@class DDPPlayerListView;
@protocol DDPPlayerListViewDelegate <NSObject>

- (NSInteger)numberOfRowAtPlayerListView:(DDPPlayerListView *)view;
- (NSString *)playerListView:(DDPPlayerListView *)view titleAtRow:(NSInteger)row;
- (void)playerListView:(DDPPlayerListView *)view didSelectedRow:(NSInteger)row;
- (void)playerListView:(DDPPlayerListView *)view didDeleteWithIndexSet:(NSIndexSet *)indexSet;
- (NSInteger)currentPlayIndexAtPlayerListView:(DDPPlayerListView *)view;
@end

@interface DDPPlayerListView : NSView
@property (nonatomic, weak) id<DDPPlayerListViewDelegate> delegate;
- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
