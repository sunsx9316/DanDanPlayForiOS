//
//  HomePageItemTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageItemTableViewCell.h"
#import "HomePageItemCollectionViewCell.h"
#import "JHEdgeButton.h"

@interface HomePageItemTableViewCell ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) JHEdgeButton *likeButton;
@end

@implementation HomePageItemTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.width.mas_offset(60 + jh_isPad() * 30);
            make.height.mas_offset(ITEM_CELL_HEIGHT);
            make.centerY.mas_equalTo(0);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconImgView.mas_right).mas_offset(10);
            make.top.mas_offset(10);
        }];
        
        [self.likeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel.mas_right);
            make.right.mas_offset(-5);
            make.centerY.equalTo(self.titleLabel);
        }];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(10);
            make.left.equalTo(self.iconImgView.mas_right).mas_offset(10);
            make.right.mas_offset(-10);
            make.height.mas_equalTo(NORMAL_SIZE_FONT.lineHeight + 15);
            make.bottom.mas_offset(-10);
        }];
    }
    return self;
}

- (void)setModel:(JHHomeBangumi *)model {
    _model = model;
    [self.iconImgView jh_setImageWithURL:_model.imageURL];
    self.titleLabel.text = _model.name;
    self.likeButton.selected = _model.isFavorite;
    self.likeButton.hidden = [CacheManager shareCacheManager].user == nil;
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.collection.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomePageItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomePageItemCollectionViewCell" forIndexPath:indexPath];
    JHHomeBangumiSubtitleGroup *model = self.model.collection[indexPath.item];
    [cell.button setTitle:model.name forState:UIControlStateNormal];
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    JHHomeBangumiSubtitleGroup *model = self.model.collection[indexPath.item];
    NSValue *value = [model getAssociatedValueForKey:_cmd];
    if (value) {
        return value.CGSizeValue;
    }
    
    CGSize size = [model.name sizeForFont:NORMAL_SIZE_FONT size:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) mode:NSLineBreakByWordWrapping];
    size.width += 10;
    size.height += 10;
    [model setAssociateValue:[NSValue valueWithCGSize:size] withKey:_cmd];
    return size;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedItemCallBack) {
        self.selectedItemCallBack(self.model.collection[indexPath.item]);
    }
}

#pragma mark - 私有方法
- (void)touchLikeButton:(UIButton *)button {
    if (self.touchLikeCallBack) {
        self.touchLikeCallBack(_model);
    }
}

#pragma mark - 懒加载
- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImgView.clipsToBounds = YES;
        [self.contentView addSubview:_iconImgView];
    }
    return _iconImgView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (JHEdgeButton *)likeButton {
    if (_likeButton == nil) {
        _likeButton = [[JHEdgeButton alloc] init];
        _likeButton.inset = CGSizeMake(20, 20);
        [_likeButton setImage:[UIImage imageNamed:@"home_like"] forState:UIControlStateSelected];
        [_likeButton setImage:[UIImage imageNamed:@"home_unlike"] forState:UIControlStateNormal];
        [_likeButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_likeButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_likeButton addTarget:self action:@selector(touchLikeButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_likeButton];
    }
    return _likeButton;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[HomePageItemCollectionViewCell class] forCellWithReuseIdentifier:@"HomePageItemCollectionViewCell"];
        [self.contentView addSubview:_collectionView];
    }
    return _collectionView;
}

@end
