//
//  SMBInputTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/2.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBInputTableViewCell.h"
@implementation SMBInputTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(5, 10, 5, 10));
        }];
    }
    return self;
}

#pragma mark - 懒加载
- (UITextField *)textField {
    if (_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.font = NORMAL_SIZE_FONT;
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        [self.contentView addSubview:_textField];
    }
    return _textField;
}

@end
