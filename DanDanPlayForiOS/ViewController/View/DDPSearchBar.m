//
//  DDPSearchBar.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSearchBar.h"

@implementation DDPSearchBar
- (UITextField *)textField {
    if (@available(iOS 13.0, *)) {
        return self.searchTextField;
    } else {
        return [self valueForKey:@"_searchField"];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImage = [[UIImage alloc] init];
        self.tintColor = [UIColor ddp_mainColor];
        self.textField.backgroundColor = [UIColor whiteColor];
        self.textField.font = [UIFont ddp_normalSizeFont];
    }
    return self;
}

@end
