//
//  FileManagerBaseViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/1.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerBaseViewCell.h"

@interface FileManagerBaseViewCell ()
@property (strong, nonatomic) UIImageView *cheakmarkImgView;
@end

@implementation FileManagerBaseViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView bringSubviewToFront:self.maskView];
}

#pragma mark - 懒加载

- (UIView *)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc] init];
        _maskView.hidden = YES;
        _maskView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
        [_maskView addSubview:self.cheakmarkImgView];
        
        [self.cheakmarkImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_offset(-5);
        }];
        
        [self.contentView addSubview:_maskView];
    }
    return _maskView;
}

- (UIImageView *)cheakmarkImgView {
    if (_cheakmarkImgView == nil) {
        _cheakmarkImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cheak_mark"]];
    }
    return _cheakmarkImgView;
}

@end
