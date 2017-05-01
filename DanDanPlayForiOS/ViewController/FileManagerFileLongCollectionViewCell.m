//
//  FileManagerFileLongCollectionViewCell
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerFileLongCollectionViewCell.h"

@interface FileManagerFileLongCollectionViewCell ()
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *bgImgView;
@property (strong, nonatomic) UIView *grayView;
@end

@implementation FileManagerFileLongCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.grayView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
//            make.height.mas_equalTo(60);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.grayView).mas_equalTo(UIEdgeInsetsMake(10, 5, 5, 5));
        }];
    }
    return self;
}

- (void)setModel:(VideoModel *)model {
    _model = model;
    self.nameLabel.text = [_model fileNameWithPathExtension];
    
    [self.bgImgView jh_setImageWithURL:[NSURL URLWithString:_model.quickHash]];
    if ([[YYWebImageManager sharedManager].cache containsImageForKey:_model.quickHash] == NO) {
        [[ToolsManager shareToolsManager] videoSnapShotWithModel:_model completion:^(UIImage *image) {
            if (image == nil) return;
            
            [self.bgImgView jh_setImageWithFadeType:image];
        }];
    }
}

#pragma mark - 懒加载
- (UILabel *)nameLabel {
	if(_nameLabel == nil) {
		_nameLabel = [[UILabel alloc] init];
        _nameLabel.font = NORMAL_SIZE_FONT;
        _nameLabel.numberOfLines = 2;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _nameLabel.textColor = [UIColor whiteColor];
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

- (UIView *)grayView {
	if(_grayView == nil) {
		_grayView = [[UIView alloc] init];
        _grayView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
//        _grayImgView.image = [UIImage imageNamed:@"comment_gradual_gray"];
        [self.contentView addSubview:_grayView];
	}
	return _grayView;
}

@end
