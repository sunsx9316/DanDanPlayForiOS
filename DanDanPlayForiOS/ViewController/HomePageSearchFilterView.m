//
//  HomePageSearchFilterView.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/7.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "HomePageSearchFilterView.h"

#define CELL_HEIGHT 44

#define TYPE_DEFAULT_STRING @"全部分类"
#define SUB_GROUP_DEFAULT_STRING @"全部字幕组"

@interface HomePageSearchFilterView ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UIButton *typeButton;
@property (strong, nonatomic) UIButton *subGroupButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *bgView;
@end

@implementation HomePageSearchFilterView
{
    NSArray <NSString *>*_currentArr;
    NSString *_selectedTypeName;
    NSString *_selectedSubGroupName;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
        
        [self.typeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.mas_equalTo(0);
            make.height.mas_equalTo(FILTER_VIEW_HEIGHT);
        }];
        
        [self.subGroupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.mas_equalTo(0);
            make.left.equalTo(self.typeButton.mas_right);
            make.size.equalTo(self.typeButton);
        }];
        
        UIView *centerLine = [[UIView alloc] init];
        centerLine.backgroundColor = RGBCOLOR(230, 230, 230);
        [self addSubview:centerLine];
        [centerLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(10);
            make.bottom.equalTo(self.typeButton).mas_offset(-10);
            make.width.mas_equalTo(1);
            make.centerX.mas_equalTo(0);
        }];
        
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.backgroundColor = RGBCOLOR(230, 230, 230);
        [self addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.typeButton);
            make.height.mas_equalTo(1);
            make.left.right.mas_equalTo(0);
        }];

        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.typeButton.mas_bottom);
            make.left.right.height.mas_equalTo(0);
        }];
    }
    return self;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil;
    }
    return view;
}

- (void)reload {
    [self.typeButton setTitle:TYPE_DEFAULT_STRING forState:UIControlStateNormal];
    [self.subGroupButton setTitle:SUB_GROUP_DEFAULT_STRING forState:UIControlStateNormal];
    [self.tableView reloadData];
}

- (NSString *)subGroupName {
    return _selectedSubGroupName;
}

- (NSString *)typeName {
    return _selectedTypeName;
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return _currentArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
        cell.textLabel.font = NORMAL_SIZE_FONT;
    }
    
    if (indexPath.section == 0) {
        if (_currentArr == self.subGroups) {
            cell.textLabel.text = SUB_GROUP_DEFAULT_STRING;
            cell.accessoryType = _selectedSubGroupName == nil ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else {
            cell.textLabel.text = TYPE_DEFAULT_STRING;
            cell.accessoryType = _selectedTypeName == nil ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    else {
        NSString *data = _currentArr[indexPath.row];
        cell.textLabel.text = data;
        if (_currentArr == self.subGroups) {
            cell.accessoryType = [_selectedSubGroupName isEqual:data] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else {
            cell.accessoryType = [_selectedTypeName isEqual:data] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_currentArr == self.types) {
        if (self.selectedTypeCallBack) {
            if (indexPath.section == 0) {
                _selectedTypeName = nil;
                self.selectedTypeCallBack(nil);
            }
            else {
                _selectedTypeName = self.types[indexPath.row];
                self.selectedTypeCallBack(_selectedTypeName);
            }
            
            [self dismissWithOut:^{
                [self.typeButton setTitle:_selectedTypeName ? _selectedTypeName : TYPE_DEFAULT_STRING forState:UIControlStateNormal];
            }];
        }
    }
    else {
        if (self.selectedSubGroupsCallBack) {
            if (indexPath.section == 0) {
                _selectedSubGroupName = nil;
                self.selectedSubGroupsCallBack(nil);
            }
            else {
                _selectedSubGroupName = self.subGroups[indexPath.row];
                self.selectedSubGroupsCallBack(_selectedSubGroupName);
            }
            
            [self dismissWithOut:^{
                [self.subGroupButton setTitle:_selectedSubGroupName ? _selectedSubGroupName : SUB_GROUP_DEFAULT_STRING forState:UIControlStateNormal];
            }];
        }
    }
    
    
}

#pragma mark - 私有方法
- (void)touchButton:(UIButton *)sender {
    if (sender.tag == 1000) {
        _currentArr = self.types;
    }
    else {
        _currentArr = self.subGroups;
    }
    
    [self.tableView reloadData];
    
    float cellHeight = CELL_HEIGHT;
    NSInteger count = _currentArr.count + 1;
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        if (count <= 4) {
            make.height.mas_equalTo(cellHeight * count);
        }
        else {
             make.height.mas_equalTo(cellHeight * 4);
        }
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
        self.bgView.alpha = 1;
    }];
}

- (void)dismissWithOut:(dispatch_block_t)animate {
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self layoutIfNeeded];
        if (animate) {
            [UIView performWithoutAnimation:animate];
        }
        self.bgView.alpha = 0;
    }];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.rowHeight = CELL_HEIGHT;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        _bgView.alpha = 0;
        @weakify(self)
        [_bgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            if (!self) return;
            
            [self dismissWithOut:nil];
        }]];
        [self addSubview:_bgView];
    }
    return _bgView;
}

- (UIButton *)typeButton {
    if (_typeButton == nil) {
        _typeButton = [[UIButton alloc] init];
        _typeButton.titleLabel.font = NORMAL_SIZE_FONT;
        _typeButton.backgroundColor = BACK_GROUND_COLOR;
        [_typeButton setTitle:TYPE_DEFAULT_STRING forState:UIControlStateNormal];
        [_typeButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_typeButton addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
        _typeButton.tag = 1000;
        [self addSubview:_typeButton];
    }
    return _typeButton;
}

- (UIButton *)subGroupButton {
    if (_subGroupButton == nil) {
        _subGroupButton = [[UIButton alloc] init];
        [_subGroupButton setTitle:SUB_GROUP_DEFAULT_STRING forState:UIControlStateNormal];
        _subGroupButton.titleLabel.font = NORMAL_SIZE_FONT;
        _subGroupButton.backgroundColor = BACK_GROUND_COLOR;
        [_subGroupButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        [_subGroupButton addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
        _subGroupButton.tag = 1002;
        [self addSubview:_subGroupButton];
    }
    return _subGroupButton;
}

@end
