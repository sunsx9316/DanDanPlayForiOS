//
//  LocalFileTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "LocalFileTableViewCell.h"

@interface LocalFileTableViewCell ()
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *bgImgView;
@property (strong, nonatomic) UIImageView *grayImgView;
@end

@implementation LocalFileTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.grayImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.height.mas_equalTo(60);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.grayImgView).mas_equalTo(UIEdgeInsetsMake(5, 5, 5, 5));
        }];
    }
    return self;
}

- (void)setModel:(VideoModel *)model {
    _model = model;
    self.nameLabel.text = [_model fileName];
    
}

#pragma mark - 懒加载
- (UILabel *)nameLabel {
	if(_nameLabel == nil) {
		_nameLabel = [[UILabel alloc] init];
        _nameLabel.font = NORMAL_SIZE_FONT;
        _nameLabel.numberOfLines = 2;
        [self.contentView addSubview:_nameLabel];
	}
	return _nameLabel;
}

- (UIImageView *)bgImgView {
	if(_bgImgView == nil) {
		_bgImgView = [[UIImageView alloc] init];
        _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImgView.clipsToBounds = YES;
        [self.contentView addSubview:_bgImgView];
	}
	return _bgImgView;
}

- (UIImageView *)grayImgView {
	if(_grayImgView == nil) {
		_grayImgView = [[UIImageView alloc] init];
        _grayImgView.image = [UIImage imageNamed:@"comment_gradual_gray"];
        [self.contentView addSubview:_grayImgView];
	}
	return _grayImgView;
}

@end
