//
//  DDPEmailListView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/10/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPEmailListView.h"
#import "DDPBaseTableView.h"
#import "UITableViewCell+Tools.h"

@interface DDPEmailListView ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) NSArray <NSString *>*dataSource;
@end

@implementation DDPEmailListView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 2;
        self.layer.shadowOffset = CGSizeMake(1, 1);
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (void)setInputString:(NSString *)inputString {
    _inputString = inputString;
    
    [self.tableView reloadData];
}

- (NSString *)adviseEmailWithInputString:(NSString *)str {
    if (str.length == 0) return nil;
    
    __block NSString *tempStr = nil;
    [self.dataSource enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj hasPrefix:str]) {
            tempStr = obj;
            *stop = YES;
        }
    }];
    
    return tempStr;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    if (cell.fromCache == NO) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont ddp_normalSizeFont];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.fromCache = YES;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@@%@", _inputString.length ? _inputString : @"", self.dataSource[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.didSelectedRowCallBack) {
        self.didSelectedRowCallBack(cell.textLabel.text);
    }
}

#pragma mark - 懒加载
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<NSString *> *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"email" ofType:@"plist"]];
    }
    return _dataSource;
}

@end
