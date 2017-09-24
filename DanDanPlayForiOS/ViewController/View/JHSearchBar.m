//
//  JHSearchBar.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHSearchBar.h"

@implementation JHSearchBar
- (UITextField *)textField {
    return [self valueForKey:@"_searchField"];
}

@end
