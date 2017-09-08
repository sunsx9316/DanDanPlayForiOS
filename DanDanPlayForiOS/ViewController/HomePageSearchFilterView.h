//
//  HomePageSearchFilterView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define FILTER_VIEW_HEIGHT 44

@interface HomePageSearchFilterView : UIView
@property (copy, nonatomic, readonly) NSString *typeName;
@property (copy, nonatomic, readonly) NSString *subGroupName;

@property (strong, nonatomic) NSArray <NSString *>*subGroups;
@property (strong, nonatomic) NSArray <NSString *>*types;
- (void)reload;

@property (copy, nonatomic) void(^selectedSubGroupsCallBack)(NSString *subGroupName);
@property (copy, nonatomic) void(^selectedTypeCallBack)(NSString *typeName);
@end
