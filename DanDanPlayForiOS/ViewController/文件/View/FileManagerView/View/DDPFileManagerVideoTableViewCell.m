//
//  DDPFileManagerVideoTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPFileManagerVideoTableViewCell.h"
#import "DDPEdgeLabel.h"
#import "UIImage+Tools.h"

@interface DDPFileManagerVideoTableViewCell ()
@property (strong, nonatomic) UIImageView *imgView;
@end

@implementation DDPFileManagerVideoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) { 
        [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.centerY.mas_equalTo(0);
            make.top.greaterThanOrEqualTo(self.contentView).offset(10);
            make.bottom.lessThanOrEqualTo(self.contentView).offset(-10);
        }];
        
        [self.fileTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imgView);
            make.height.equalTo(self.fileTypeLabel.mas_width);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).mas_offset(10);
            make.bottom.mas_offset(-10);
            make.top.mas_offset(10);
            make.right.mas_offset(-10);
        }];
    }
    return self;
}

- (void)setModel:(DDPSMBFile *)model {
    _model = model;
    self.titleLabel.text = _model.name;
    if (ddp_isVideoFile(_model.fileURL.absoluteString)) {
        self.fileTypeLabel.text = _model.fileURL.pathExtension;
//        self.imgView.hidden = NO;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).mas_offset(10);
        }];
        
        [self.fileTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40 + ddp_isPad() * 10);
        }];
    }
    else {
        self.fileTypeLabel.text = nil;
//        self.imgView.hidden = YES;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.imgView.mas_right).mas_offset(0);
        }];
        
        [self.fileTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
    }
}

#pragma mark - 懒加载
- (UIImageView *)imgView {
    if (_imgView == nil) {
        var img = [[UIImage imageNamed:@"comment_file_type"] renderByMainColor];
        _imgView = [[UIImageView alloc] initWithImage:img];
        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}

- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont ddp_normalSizeFont];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)fileTypeLabel {
    if(_fileTypeLabel == nil) {
        _fileTypeLabel = [[UILabel alloc] init];
        _fileTypeLabel.font = [UIFont ddp_smallSizeFont];
        _fileTypeLabel.numberOfLines = 0;
        _fileTypeLabel.textAlignment = NSTextAlignmentCenter;
        _fileTypeLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [_fileTypeLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_fileTypeLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        _fileTypeLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:_fileTypeLabel];
    }
    return _fileTypeLabel;
}

@end
