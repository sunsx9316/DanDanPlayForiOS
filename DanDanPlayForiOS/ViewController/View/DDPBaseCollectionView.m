//
//  DDPBaseCollectionView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/29.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseCollectionView.h"

@interface DDPBaseCollectionView ()<DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation DDPBaseCollectionView

- (void)endRefreshing {
    if (self.mj_header.isRefreshing) {
        [self.mj_header endRefreshing];
    }
    
    if (self.mj_footer.isRefreshing) {
        [self.mj_footer endRefreshing];
    }
    
    self.showEmptyView = YES;
    [self reloadEmptyDataSet];
}


- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.emptyDataSetSource = self;
        self.emptyDataSetDelegate = self;
        self.backgroundColor = [UIColor ddp_backgroundColor];
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return self;
}

@end
