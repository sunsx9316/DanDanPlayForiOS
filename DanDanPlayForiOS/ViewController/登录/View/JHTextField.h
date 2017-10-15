//
//  JHTextField.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JHTextFieldType) {
    JHTextFieldTypeNormal,
    JHTextFieldTypePassword,
};

@interface JHTextField : UITextField
@property (strong, nonatomic, readonly) UIButton *rightButton;
@property (strong, nonatomic, readonly) UIView *lineView;
@property (assign, nonatomic) NSUInteger limit;

- (instancetype)initWithType:(JHTextFieldType)type;
- (void)touchSeeButton:(UIButton *)sender;
@end
