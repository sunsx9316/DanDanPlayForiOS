//
//  FileManagerBaseViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/1.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "FileManagerBaseViewCell.h"

@interface FileManagerBaseViewCell ()

@end

@implementation FileManagerBaseViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
