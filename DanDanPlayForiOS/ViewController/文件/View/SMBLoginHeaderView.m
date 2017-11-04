//
//  SMBLoginHeaderView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/7/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SMBLoginHeaderView.h"

@interface SMBLoginHeaderView ()

@end

@implementation SMBLoginHeaderView

//- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
//        [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.mas_equalTo(0);
//            make.left.equalTo(self.titleLabel.mas_right).mas_offset(10);
//        }];
//    }
//    return self;
//}
//
//- (void)touchAddButton:(UIButton *)sender {
//    if (self.touchAddButtonCallback) {
//        self.touchAddButtonCallback();
//    }
//}
//
//#pragma mark - 懒加载
//
//- (UIButton *)addButton {
//    if (_addButton == nil) {
//        _addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
//        [_addButton addTarget:self action:@selector(touchAddButton:) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_addButton];
//    }
//    return _addButton;
//}

@end
