//
//  HomePageBangumiProgressTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageBangumiProgressTableViewCell.h"
#import "HomePageBangumiProgressCollectionViewCell.h"
#import "DDPAttentionDetailViewController.h"

@interface HomePageBangumiProgressTableViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation HomePageBangumiProgressTableViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.collectionView];
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)setCollection:(DDPBangumiQueueIntroCollection *)collection {
    _collection = collection;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.collection.collection.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomePageBangumiProgressCollectionViewCell *cell = [collectionView dequeueReusableCellWithClass:[HomePageBangumiProgressCollectionViewCell class] forIndexPath:indexPath];
    cell.itemSize = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
    cell.model = self.collection.collection[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger width = (NSInteger)((kScreenWidth - 40) / 2.5);
    return CGSizeMake(width, self.height);
}



#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        layout.minimumInteritemSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor ddp_backgroundColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = true;
        _collectionView.bounces = false;
        _collectionView.showsHorizontalScrollIndicator = false;
        [_collectionView registerCellFromXib:[HomePageBangumiProgressCollectionViewCell class]];
    }
    return _collectionView;
}

@end
