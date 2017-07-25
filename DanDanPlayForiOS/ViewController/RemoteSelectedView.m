//
//  RemoteSelectedView.m
//  TJSecurity
//
//  Created by JimHuang on 2017/6/10.
//  Copyright © 2017年 convoy. All rights reserved.
//

#import "RemoteSelectedView.h"

#define TABLE_VIEW_WIDTH (130 + jh_isPad() * 80)
#define TABLE_VIEW_HEIGHT ((44 + jh_isPad() * 40) * 2 + 20)

@interface RemoteSelectedView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIImageView *bgImgView;
@property (strong, nonatomic) UIView *gestureView;
@property (strong, nonatomic) UIVisualEffectView *blurView;
@end

@implementation RemoteSelectedView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.blurView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(TABLE_VIEW_WIDTH, TABLE_VIEW_HEIGHT));
            make.right.mas_offset(-10);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.blurView).mas_equalTo(UIEdgeInsetsMake(10, 0, 0, 0));
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)reloadData {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.textLabel.font = NORMAL_SIZE_FONT;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.textLabel.text = self.models[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.didSelctedRowWithTypeCallBack) {
        self.didSelctedRowWithTypeCallBack(self.models[indexPath.row], indexPath.row);
    }
    
    [self dismiss];
}

- (void)show {
    self.alpha = 0;
    if (self.superview == nil) {
        [[UIApplication sharedApplication].keyWindow addSubview:self];
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.tableView reloadData];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.rowHeight = 44 + jh_isPad() * 40;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (UIImageView *)bgImgView {
    if (_bgImgView == nil) {
        _bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_bg"]];
        _bgImgView.frame = CGRectMake(0, 0, TABLE_VIEW_WIDTH, TABLE_VIEW_HEIGHT);
//        [self addSubview:_bgImgView];
    }
    return _bgImgView;
}

- (UIView *)gestureView {
    if (_gestureView == nil) {
        _gestureView = [[UIView alloc] init];
        @weakify(self)
        [_gestureView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            [self dismiss];
        }]];
        
        [_gestureView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithActionBlock:^(UIPanGestureRecognizer * _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateFailed) {
                [self dismiss];
            }
        }]];
        
        [self addSubview:_gestureView];
    }
    return _gestureView;
}

- (UIVisualEffectView *)blurView {
    if (_blurView == nil) {
        _blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
//        [_blurView addSubview:self.bgImgView];
        
        _blurView.maskView = self.bgImgView;
        [self addSubview:_blurView];
    }
    return _blurView;
}

@end
