//
//  DDPPlayerTableCellView.m
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/10/13.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPPlayerTableCellView.h"
#import <Masonry/Masonry.h>

@interface DDPPlayerTableCellView ()
@property (nonatomic, strong) NSView *pointView;
@property (weak) IBOutlet NSLayoutConstraint *leftConstraint;
@end

@implementation DDPPlayerTableCellView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    let view = [[NSView alloc] init];
    [self addSubview:view];
    [view addSubview:self.pointView];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.leading.mas_equalTo(0);
        make.width.mas_equalTo(20);
    }];
    
    [self.pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(7);
        make.center.mas_equalTo(view);
    }];
}

- (void)setShowPoint:(BOOL)showPoint {
    _showPoint = showPoint;
    self.pointView.hidden = !_showPoint;
    if (_showPoint) {
        self.leftConstraint.constant = 20;
    } else {
        self.leftConstraint.constant = 5;
    }
}

- (NSView *)pointView {
    if (_pointView == nil) {
        _pointView = [[NSView alloc] init];
        _pointView.wantsLayer = YES;
        _pointView.layer.backgroundColor = [NSColor greenColor].CGColor;
        _pointView.layer.cornerRadius = 5;
        _pointView.layer.masksToBounds = YES;
    }
    return _pointView;
}

@end
