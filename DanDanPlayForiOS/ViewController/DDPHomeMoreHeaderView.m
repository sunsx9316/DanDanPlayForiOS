//
//  DDPHomeMoreHeaderView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHomeMoreHeaderView.h"

@interface DDPHomeMoreHeaderView ()
@property (strong, nonatomic) UIImageView *moreImgView;
@property (strong, nonatomic) UILabel *detailLabel;
@end

@implementation DDPHomeMoreHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self.moreImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.mas_offset(-10);
        }];
        
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.right.equalTo(self.moreImgView.mas_left).mas_offset(-5);
        }];
    }
    return self;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.touchCallBack) {
        self.touchCallBack();
    }
}

#pragma mark - 懒加载
- (UIImageView *)moreImgView {
    if (_moreImgView == nil) {
        _moreImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_right_arrow"]];
        [self.contentView addSubview:_moreImgView];
    }
    return _moreImgView;
}

- (UILabel *)detailLabel {
    if (_detailLabel == nil) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont ddp_smallSizeFont];
        _detailLabel.text = @"查看更多";
        _detailLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:_detailLabel];
    }
    return _detailLabel;
}

@end
