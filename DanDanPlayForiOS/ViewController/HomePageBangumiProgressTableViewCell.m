//
//  HomePageBangumiProgressTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageBangumiProgressTableViewCell.h"
#import "HomePageBangumiProgressCollectionViewCell.h"

@interface HomePageBangumiProgressTableViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UICollectionView *collectionView;
@end

@implementation HomePageBangumiProgressTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
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
    HomePageBangumiProgressCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomePageBangumiProgressCollectionViewCell" forIndexPath:indexPath];
    cell.itemSize = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
    cell.model = self.collection.collection[indexPath.item];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger width = (NSInteger)((kScreenWidth - 40) / 2.5);
    return CGSizeMake(width, self.height - 20);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DDPBangumiQueueIntro *model = self.collection.collection[indexPath.item];
    if (self.didSelectedBangumiCallBack) {
        self.didSelectedBangumiCallBack(model);
    }
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.minimumInteritemSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor ddp_backgroundColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerNib:[HomePageBangumiProgressCollectionViewCell loadNib] forCellWithReuseIdentifier:@"HomePageBangumiProgressCollectionViewCell"];
        [self.contentView addSubview:self.collectionView];
    }
    return _collectionView;
}

@end
