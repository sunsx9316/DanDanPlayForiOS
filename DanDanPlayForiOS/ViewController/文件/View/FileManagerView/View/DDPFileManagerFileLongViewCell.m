//
//  DDPFileManagerFileLongViewCell
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileManagerFileLongViewCell.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "UIView+Tools.h"
#import "DDPEdgeButton.h"
#import "DDPMediaPlayer.h"
#import "DDPVideoModel+Tools.h"

@interface DDPFileManagerFileLongViewCell ()
//@property (strong, nonatomic) UIView *grayView;
@end

@implementation DDPFileManagerFileLongViewCell
{
    DDPVideoModel *_model;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.selectedBackgroundView = [[UIView alloc] init];
        
        [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(0);
            make.top.left.mas_equalTo(10);
//            make.bottom.mas_offset(-10);
            make.height.mas_equalTo(80);
            make.width.equalTo(self.bgImgView.mas_height).mas_offset(30);
        }];
        
        [self.lastPlayTimeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.right.equalTo(self.bgImgView).mas_offset(-5);
        }];
        
//        [self.grayView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.right.bottom.mas_equalTo(0);
////            make.height.mas_equalTo(60);
//        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgImgView);
            make.left.equalTo(self.bgImgView.mas_right).mas_offset(10);
            make.right.mas_offset(-10);
            make.bottom.mas_offset(-10);
//            make.edges.equalTo(self.grayView).mas_equalTo(UIEdgeInsetsMake(10, 5, 5, 5));
        }];
        
    }
    return self;
}

- (void)setModel:(DDPVideoModel *)model {
    _model = model;
    
    self.nameLabel.text = [_model fileNameWithPathExtension];
    [self.bgImgView ddp_setImageWithURL:[NSURL URLWithString:_model.quickHash]];

    [_model lastPlayTimeWithBlock:^(NSInteger lastPlayTime) {
        if (lastPlayTime > 0) {
            self.lastPlayTimeButton.hidden = NO;
            [self.lastPlayTimeButton setTitle:[NSString stringWithFormat:@"• %@", ddp_mediaFormatterTime(lastPlayTime)] forState:UIControlStateNormal];
        }
        else {
            self.lastPlayTimeButton.hidden = YES;
        }
    }];

    if ([[YYWebImageManager sharedManager].cache containsImageForKey:_model.quickHash] == NO) {
        @weakify(self)
        [[DDPToolsManager shareToolsManager] videoSnapShotWithModel:_model completion:^(UIImage *image) {
            @strongify(self)
            if (!self) return;
            
            [self.bgImgView ddp_setImageWithURL:[NSURL URLWithString:_model.quickHash]];
        }];
    }
}

#pragma mark - 懒加载
- (UILabel *)nameLabel {
	if(_nameLabel == nil) {
		_nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont ddp_normalSizeFont];
        _nameLabel.numberOfLines = 0;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
//        _nameLabel.textColor = [UIColor whiteColor];
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

- (UIButton *)lastPlayTimeButton {
    if(_lastPlayTimeButton == nil) {
        DDPEdgeButton *button = [[DDPEdgeButton alloc] init];
        button.inset = CGSizeMake(6, 2);
        _lastPlayTimeButton = button;
        _lastPlayTimeButton.hidden = YES;
        _lastPlayTimeButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        [_lastPlayTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_lastPlayTimeButton setBackgroundImage:[UIImage imageNamed:@"comment_file_type"] forState:UIControlStateNormal];
        [self.contentView addSubview:_lastPlayTimeButton];
    }
    return _lastPlayTimeButton;
}

@end
