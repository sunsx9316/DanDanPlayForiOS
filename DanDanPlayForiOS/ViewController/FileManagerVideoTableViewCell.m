//
//  FileManagerVideoTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/16.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerVideoTableViewCell.h"
#import "JHEdgeLabel.h"

@interface FileManagerVideoTableViewCell ()
@property (strong, nonatomic) UIImageView *imgView;
@property (strong, nonatomic) UILabel *fileTypeLabel;
@end

@implementation FileManagerVideoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.imgView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_offset(15);
            make.centerY.mas_equalTo(0);
        }];
        
        [self.fileTypeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.imgView);
            make.height.equalTo(self.fileTypeLabel.mas_width);
        }];
        
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.fileTypeLabel.mas_right).mas_offset(10);
//            make.bottom.mas_offset(-5);
            make.right.mas_offset(-10);
            make.centerY.equalTo(self.fileTypeLabel);
        }];
    }
    return self;
}

- (void)setModel:(JHSMBFile *)model {
    _model = model;
    self.titleLabel.text = _model.name;
    if (jh_isVideoFile(_model.fileURL.absoluteString)) {
        self.fileTypeLabel.text = _model.fileURL.pathExtension;
        [self.fileTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(36);
        }];
    }
    else {
        self.fileTypeLabel.text = nil;
        [self.fileTypeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
    }
}

#pragma mark - 懒加载
- (UIImageView *)imgView {
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file_type"]];
        [self.contentView addSubview:_imgView];
    }
    return _imgView;
}

- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)fileTypeLabel {
    if(_fileTypeLabel == nil) {
        _fileTypeLabel = [[UILabel alloc] init];
        _fileTypeLabel.font = SMALL_SIZE_FONT;
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
