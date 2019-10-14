//
//  DDPNewHomePageItemViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/4.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import "DDPNewHomePageItemViewController.h"
#import "DDPAttentionDetailViewController.h"
#import "DDPNewHomePageBangumiIntroCollectionViewCell.h"
#import "DDPBaseCollectionView.h"

@interface DDPNewHomePageItemViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) DDPBaseCollectionView *collectionView;
@end

@implementation DDPNewHomePageItemViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setBangumis:(NSArray<DDPNewBangumiIntro *> *)bangumis {
    _bangumis = bangumis;
    [self resortBangumis];
    if (self.isViewLoaded) {
        [self.collectionView reloadData];
    }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.bangumis.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDPNewHomePageBangumiIntroCollectionViewCell *cell = [collectionView dequeueReusableCellWithClass:DDPNewHomePageBangumiIntroCollectionViewCell.class forIndexPath:indexPath];
    
    let size = [self collectionView:collectionView layout:collectionView.collectionViewLayout sizeForItemAtIndexPath:indexPath];
    
    cell.itemSize = size;
    cell.model = self.bangumis[indexPath.item];
    
    @weakify(self)
    cell.touchLikeButtonCallBack = ^(DDPNewBangumiIntro * _Nonnull model) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        if ([self showLoginAlert] == false) {
            return;
        }
        
        BOOL flag = !model.isFavorited;
        [self.view showLoading];
        [DDPFavoriteNetManagerOperation changeFavoriteStatusWithAnimeId:model.identity like:flag completionHandler:^(NSError *error) {
            @strongify(self)
            if (!self) {
                return;
            }
            
            [self.view hideLoading];
            
            if (error) {
                [self.view showWithError:error];
            }
            else {
                [[NSNotificationCenter defaultCenter] postNotificationName:ATTENTION_SUCCESS_NOTICE object:@(model.identity) userInfo:@{ATTENTION_KEY : @(flag)}];
            }
            
        }];
    };
    
    cell.attentionCallBack = ^(NSUInteger animateId) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ATTENTION_SUCCESS_NOTICE object:@(animateId) userInfo:@{ATTENTION_KEY : @(true)}];
    };
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = self.view.width;
    if (ddp_appType == DDPAppTypeToMac && width == 0) {
        width = 60;
    }
    
    let spacing = [self collectionView:collectionView layout:collectionView.collectionViewLayout minimumLineSpacingForSectionAtIndex:indexPath.section];
    let insetForSection = [self collectionView:collectionView layout:collectionView.collectionViewLayout insetForSectionAtIndex:indexPath.section];
    
    NSInteger rank = 3;
    
    if (ddp_isPad()) {
        rank = 5;
    }
    else if (ddp_isSmallDevice()) {
        rank = 2;
    }
    
    let itemWidth = (NSInteger)(((width - insetForSection.left - insetForSection.right) - (rank - 1) * spacing) / rank);
    return CGSizeMake(itemWidth, itemWidth + 50);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 10, 10, 10);
}


#pragma mark - 私有方法

- (void)resortBangumis {
    [(NSMutableArray *)self.bangumis sortUsingComparator:^NSComparisonResult(DDPNewBangumiIntro * _Nonnull obj1, DDPNewBangumiIntro * _Nonnull obj2) {
        if (obj2.isFavorited == obj1.isFavorited) {
            return [obj1.name compare:obj2.name];
        }
        return obj2.isFavorited - obj1.isFavorited;
    }];
}

#pragma mark - 懒加载
- (DDPBaseCollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[DDPBaseCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.titleForEmptyView = @"在右边添加关注的新番（￣︶￣）↗";
        _collectionView.descriptionForEmptyView = @"";
        _collectionView.verticalOffsetForEmptyDataSet = -50;
        _collectionView.showEmptyView = true;
        _collectionView.showsVerticalScrollIndicator = NO;
        
        [_collectionView registerCellFromXib:[DDPNewHomePageBangumiIntroCollectionViewCell class]];
    }
    return _collectionView;
}


@end
