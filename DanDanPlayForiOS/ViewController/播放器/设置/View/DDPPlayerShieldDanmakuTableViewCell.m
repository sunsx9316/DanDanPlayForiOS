//
//  DDPPlayerShieldDanmakuTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/4/16.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPPlayerShieldDanmakuTableViewCell.h"
#import "DDPPlayerShieldDanmakuCollectionViewCell.h"

#define TITLE_KEY @"title"

@interface DDPPlayerShieldDanmakuTableViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;


@property (strong, nonatomic) NSDictionary <NSNumber *, NSDictionary *>*shadowStyleDic;
@property (strong, nonatomic) NSDictionary <NSNumber *, NSDictionary *>*fieldStyleDic;

@property (strong, nonatomic) NSArray <NSNumber *>*shadowStyleArr;
@property (strong, nonatomic) NSArray <NSNumber *>*fieldStyleArr;
@end

@implementation DDPPlayerShieldDanmakuTableViewCell
{
    __weak NSDictionary <NSNumber *, NSDictionary *>*_currentDic;
    __weak NSArray <NSNumber *>*_currentArr;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.collectionView.layer.borderColor = [UIColor ddp_mainColor].CGColor;
    self.collectionView.layer.borderWidth = 1;
    self.collectionView.layer.cornerRadius = 6;
    self.collectionView.layer.masksToBounds = true;
    
    [self.collectionView registerNib:[DDPPlayerShieldDanmakuCollectionViewCell loadNib] forCellWithReuseIdentifier:[DDPPlayerShieldDanmakuCollectionViewCell className]];
}

- (void)setType:(DDPPlayerShieldDanmakuTableViewCellType)type {
    
    if (type == _type) return;
    
    _type = type;
    
    if (self.type == DDPPlayerShieldDanmakuTableViewCellTypeShadow) {
        _currentArr = self.shadowStyleArr;
        _currentDic = self.shadowStyleDic;
    }
    else {
        _currentArr = self.fieldStyleArr;
        _currentDic = self.fieldStyleDic;
    }
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _currentDic.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DDPPlayerShieldDanmakuCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DDPPlayerShieldDanmakuCollectionViewCell className] forIndexPath:indexPath];
    
    cell.titleLabel.text = _currentDic[_currentArr[indexPath.item]][TITLE_KEY];
    
    if (self.type == DDPPlayerShieldDanmakuTableViewCellTypeShadow) {
        cell.selected = _currentArr[indexPath.item].integerValue == [DDPCacheManager shareCacheManager].danmakuEffectStyle;
    }
    else {
        DDPDanmakuShieldType danmakuShieldType = [DDPCacheManager shareCacheManager].danmakuShieldType;
        cell.selected = _currentArr[indexPath.item].integerValue & danmakuShieldType;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //单选
    if (self.type == DDPPlayerShieldDanmakuTableViewCellTypeShadow) {
        [DDPCacheManager shareCacheManager].danmakuEffectStyle = _currentArr[indexPath.item].integerValue;
    }
    else {
        DDPDanmakuShieldType danmakuShieldType = [DDPCacheManager shareCacheManager].danmakuShieldType;
        DDPDanmakuShieldType selectedType = _currentArr[indexPath.item].integerValue;
        //如果已经屏蔽了此类型弹幕 则取消选择 否则添加此类型弹幕
        if (danmakuShieldType & selectedType) {
            NSInteger temp = ~selectedType;
            danmakuShieldType = danmakuShieldType & temp;
        }
        else {
            danmakuShieldType = danmakuShieldType | selectedType;
        }
        [DDPCacheManager shareCacheManager].danmakuShieldType = danmakuShieldType;
    }
    [collectionView reloadData];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemCount = [self collectionView:collectionView numberOfItemsInSection:0];
    return CGSizeMake((NSInteger)(collectionView.width / itemCount), collectionView.height);
}

#pragma mark - 懒加载
- (NSDictionary<NSNumber *,NSDictionary *> *)shadowStyleDic {
    if (_shadowStyleDic == nil) {
        _shadowStyleDic = @{@(JHDanmakuEffectStyleNone) : @{TITLE_KEY : @"无"},
                            @(JHDanmakuEffectStyleStroke) : @{TITLE_KEY : @"描边"},
                            @(JHDanmakuEffectStyleShadow) : @{TITLE_KEY : @"投影"},
                            @(JHDanmakuEffectStyleGlow) : @{TITLE_KEY : @"模糊阴影"}
                            
                            };
    }
    return _shadowStyleDic;
}

- (NSDictionary<NSNumber *,NSDictionary *> *)fieldStyleDic {
    if (_fieldStyleDic == nil) {
        _fieldStyleDic = @{@(DDPDanmakuShieldTypeScroll) : @{TITLE_KEY : @"滚动"},
                           @(DDPDanmakuShieldTypeFloatAtTo) : @{TITLE_KEY : @"顶部"},
                           @(DDPDanmakuShieldTypeFloatAtBottom) : @{TITLE_KEY : @"底部"},
                           @(DDPDanmakuShieldTypeColor) : @{TITLE_KEY : @"彩色"}
                           
                           };
    }
    return _fieldStyleDic;
}

- (NSArray<NSNumber *> *)shadowStyleArr {
    if (_shadowStyleArr == nil) {
        _shadowStyleArr = @[@(JHDanmakuEffectStyleNone),
                            @(JHDanmakuEffectStyleStroke),
                            @(JHDanmakuEffectStyleShadow),
                            @(JHDanmakuEffectStyleGlow)];
    }
    return _shadowStyleArr;
}

- (NSArray<NSNumber *> *)fieldStyleArr {
    if (_fieldStyleArr == nil) {
        _fieldStyleArr = @[@(DDPDanmakuShieldTypeScroll),
                            @(DDPDanmakuShieldTypeFloatAtTo),
                            @(DDPDanmakuShieldTypeFloatAtBottom),
                            @(DDPDanmakuShieldTypeColor)];
    }
    return _fieldStyleArr;
}

@end
