//
//  DDPPlayerShadowStyleTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/24.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPPlayerShadowStyleTableViewCell.h"

@interface DDPPlayerShadowStyleTableViewCell ()
@property (strong, nonatomic) UISegmentedControl *segmentedControl;
@end

@implementation DDPPlayerShadowStyleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(5, 5, 5, 5));
        }];
    }
    return self;
}

#pragma mark - 私有方法
- (void)touchSegmentedControl:(UISegmentedControl *)sender {
    [DDPCacheManager shareCacheManager].danmakuShadowStyle = sender.selectedSegmentIndex + 100;
}


#pragma mark - 懒加载
- (UISegmentedControl *)segmentedControl {
    if (_segmentedControl == nil) {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"无", @"描边", @"投影", @"模糊阴影"]];
        _segmentedControl.tintColor = [UIColor ddp_mainColor];
        [_segmentedControl addTarget:self action:@selector(touchSegmentedControl:) forControlEvents:UIControlEventValueChanged];
        if (ddp_isPad()) {
            [_segmentedControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont]} forState:UIControlStateSelected];
            [_segmentedControl setTitleTextAttributes:@{NSFontAttributeName : [UIFont ddp_normalSizeFont]} forState:UIControlStateNormal];            
        }
        _segmentedControl.selectedSegmentIndex = [DDPCacheManager shareCacheManager].danmakuShadowStyle - 100;
        [self.contentView addSubview:_segmentedControl];
    }
    return _segmentedControl;
}

@end
