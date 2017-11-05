//
//  AttentionDetailTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/8.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AttentionDetailTableViewCell.h"
#import "NSDate+Tools.h"
#import "JHEdgeLabel.h"
#import "YYPhotoBrowseView.h"
#import "JHEdgeButton.h"

@interface AttentionDetailTableViewCell ()
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) JHEdgeLabel *onAirLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *viewLabel;
@property (strong, nonatomic) JHEdgeButton *searchButton;
@property (strong, nonatomic) UIVisualEffectView *blurView;
@end

@implementation AttentionDetailTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(10);
            make.width.mas_offset(80 + jh_isPad() * 30);
            make.height.mas_offset(DETAIL_CELL_HEIGHT);
            make.centerY.mas_equalTo(0);
        }];
        
        [self.onAirLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(self.iconImgView).mas_offset(-5);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.iconImgView);
            make.left.equalTo(self.iconImgView.mas_right).mas_offset(10);
            make.right.mas_offset(-10);
        }];
        
        [self.viewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.nameLabel.mas_bottom).mas_offset(10);
            make.left.equalTo(self.nameLabel);
            make.right.mas_offset(-10);
            make.centerY.mas_equalTo(0);
        }];
        
        [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.bottom.mas_equalTo(self.iconImgView);
        }];
    }
    return self;
}

- (void)setModel:(JHPlayHistory *)model {
    _model = model;
    [self.iconImgView jh_setImageWithURL:_model.imageUrl placeholder:nil];
    [self.blurView.layer jh_setImageWithURL:_model.imageUrl];
    self.onAirLabel.text = self.model.playHistoryStatusString;
//    self.onAirLabel.hidden = !_model.isOnAir;
    self.nameLabel.text = _model.name;
    
    __block NSUInteger episodeWatched = 0;
    [_model.collection enumerateObjectsUsingBlock:^(JHEpisode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.time.length) {
            episodeWatched++;
        }
    }];
    
    self.viewLabel.text = [NSString stringWithFormat:@"已看%ld集 , 共%ld集",  episodeWatched, _model.collection.count];
}

- (void)touchSearchButton:(UIButton *)sender {
    if (self.touchSearchButtonCallBack) {
        self.touchSearchButtonCallBack(self.model);
    }
}

#pragma mark - 懒加载
- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] init];
        _iconImgView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImgView.clipsToBounds = YES;
        _iconImgView.userInteractionEnabled = YES;
        @weakify(self)
        [_iconImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer * _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            YYPhotoGroupItem *item = [[YYPhotoGroupItem alloc] init];
            item.largeImageURL = _model.imageUrl;
            YYPhotoBrowseView *view = [[YYPhotoBrowseView alloc] initWithGroupItems:@[item]];
            [view presentFromImageView:self.iconImgView toContainer:[UIApplication sharedApplication].keyWindow animated:YES completion:nil];
        }]];
        [self.contentView addSubview:_iconImgView];
    }
    return _iconImgView;
}

- (JHEdgeLabel *)onAirLabel {
    if (_onAirLabel == nil) {
        _onAirLabel = [[JHEdgeLabel alloc] init];
        _onAirLabel.font = SMALL_SIZE_FONT;
        _onAirLabel.textColor = [UIColor whiteColor];
        _onAirLabel.text = @"连载中";
        _onAirLabel.textAlignment = NSTextAlignmentCenter;
        _onAirLabel.backgroundColor = MAIN_COLOR;
        _onAirLabel.inset = CGSizeMake(5, 5);
        [self.contentView addSubview:_onAirLabel];
    }
    return _onAirLabel;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = NORMAL_SIZE_FONT;
        _nameLabel.numberOfLines = 2;
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_nameLabel];
    }
    return _nameLabel;
}

- (UILabel *)viewLabel {
    if (_viewLabel == nil) {
        _viewLabel = [[UILabel alloc] init];
        _viewLabel.font = SMALL_SIZE_FONT;
        _viewLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_viewLabel];
    }
    return _viewLabel;
}

- (JHEdgeButton *)searchButton {
    if (_searchButton == nil) {
        _searchButton = [[JHEdgeButton alloc] init];
        _searchButton.titleLabel.font = SMALL_SIZE_FONT;
        [_searchButton setTitle:@"搜索资源" forState:UIControlStateNormal];
        [_searchButton setImage:[[UIImage imageNamed:@"home_search"] yy_imageByResizeToSize:CGSizeMake(18, 18)] forState:UIControlStateNormal];
        [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _searchButton.inset = CGSizeMake(10, 0);
        _searchButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_searchButton addTarget:self action:@selector(touchSearchButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_searchButton];
    }
    return _searchButton;
}

- (UIVisualEffectView *)blurView {
    if (_blurView == nil) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
        _blurView.layer.contentMode = UIViewContentModeScaleAspectFill;
        _blurView.clipsToBounds = YES;
        [self.contentView addSubview:_blurView];
    }
    return _blurView;
}

@end
