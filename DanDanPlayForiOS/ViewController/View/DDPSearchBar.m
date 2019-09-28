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

@end
