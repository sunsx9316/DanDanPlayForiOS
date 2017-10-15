//
//  DanmakuSelectedFontViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DanmakuSelectedFontViewController.h"
#import "JHBaseTableView.h"
#import "FTPReceiceTableViewCell.h"
#import "UIFont+Tools.h"
#import "TextHeaderView.h"

@interface DanmakuSelectedFontViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) NSArray <NSDictionary <NSString *, NSArray *>*>*fonts;
@end

@implementation DanmakuSelectedFontViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"选择弹幕字体";
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    if (self.tableView.mj_header.refreshingBlock) {
        self.tableView.mj_header.refreshingBlock();
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIFont *danmakuFont = [CacheManager shareCacheManager].danmakuFont;
    if (indexPath.section == 0) {
        UIFont *tempFont = [UIFont systemFontOfSize:danmakuFont.pointSize];
        tempFont.isSystemFont = YES;
        [CacheManager shareCacheManager].danmakuFont = tempFont;
    }
    else {
        NSDictionary *dic = self.fonts[indexPath.section - 1];
        NSArray *arr = dic.allValues.firstObject;
        UIFont *tempFont = [UIFont fontWithName:arr[indexPath.row] size:danmakuFont.pointSize];
        tempFont.isSystemFont = NO;
        [CacheManager shareCacheManager].danmakuFont = tempFont;
    }
    
    [tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TextHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TextHeaderView"];
    if (section == 0) {
        view.titleLabel.text = @"系统字体";
    }
    else {
        view.titleLabel.text = self.fonts[section - 1].allKeys.firstObject;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 + self.fonts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    NSDictionary *dic = self.fonts[section - 1];
    NSArray *arr = dic.allValues.firstObject;
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FTPReceiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FTPReceiceTableViewCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        cell.titleLabel.text = @"系统字体";
        cell.titleLabel.font = NORMAL_SIZE_FONT;
    }
    else {
        NSDictionary *dic = self.fonts[indexPath.section - 1];
        NSArray *arr = dic.allValues.firstObject;
        
        UIFont *font = [UIFont fontWithName:arr[indexPath.row] size:NORMAL_SIZE_FONT.pointSize];
        cell.titleLabel.text = font.fontName;
        cell.titleLabel.font = font;
    }
    
    UIFont *danmakuFont = [CacheManager shareCacheManager].danmakuFont;
    
    if (indexPath.section == 0) {
        cell.iconImgView.hidden = !danmakuFont.isSystemFont;
    }
    else {
        NSDictionary *dic = self.fonts[indexPath.section - 1];
        NSArray *arr = dic.allValues.firstObject;
        
        cell.iconImgView.hidden = ![danmakuFont.fontName isEqualToString:arr[indexPath.row]];
    }
    
    return cell;
    
}

#pragma mark - 懒加载
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowScroll = YES;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 44;
        
        [_tableView registerClass:[FTPReceiceTableViewCell class] forCellReuseIdentifier:@"FTPReceiceTableViewCell"];
        [_tableView registerClass:[TextHeaderView class] forHeaderFooterViewReuseIdentifier:@"TextHeaderView"];
        
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableArray <NSMutableDictionary *>*fonts = [NSMutableArray array];
                NSArray<NSString *> *familyNames = [UIFont familyNames];
                [familyNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSArray *arr = [UIFont fontNamesForFamilyName:obj];
                    if (arr.count) {
                        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                        dic[obj] = arr;
                        [fonts addObject:dic];
                    }
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView.mj_header endRefreshing];
                    self.fonts = fonts;
                    [self.tableView reloadData];
                });
            });
        }];
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

@end
