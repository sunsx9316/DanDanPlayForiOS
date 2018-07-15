//
//  DDPTextField.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/10.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DDPTextFieldType) {
    DDPTextFieldTypeNormal,
    DDPTextFieldTypePassword,
};

@interface DDPTextField : UIView
@property (strong, nonatomic, readonly) UIButton *rightButton;
@property (strong, nonatomic, readonly) UIView *lineView;
@property (assign, nonatomic) NSUInteger limit;
@property (strong, nonatomic) UITextField *textField;

- (instancetype)initWithType:(DDPTextFieldType)type;
@end

