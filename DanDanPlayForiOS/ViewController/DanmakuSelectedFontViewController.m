//
//  DanmakuSelectedFontViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DanmakuSelectedFontViewController.h"
#import "BaseTableView.h"
#import "FTPReceiceTableViewCell.h"

@interface DanmakuSelectedFontViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) BaseTableView *tableView;
@property (strong, nonatomic) NSArray <NSString *>*fonts;
@end

@implementation DanmakuSelectedFontViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择弹幕字体";
    
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
        [CacheManager shareCacheManager].danmakuFont = [UIFont systemFontOfSize:danmakuFont.pointSize];
    }
    else {
        [CacheManager shareCacheManager].danmakuFont = [UIFont fontWithName:self.fonts[indexPath.row] size:danmakuFont.pointSize];
    }
    
    [tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0 ? 1 : self.fonts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FTPReceiceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FTPReceiceTableViewCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        UIFont *font = [UIFont systemFontOfSize:NORMAL_SIZE_FONT.pointSize];
        cell.titleLabel.text = [NSString stringWithFormat:@"%@（默认）", font.fontName];
        cell.titleLabel.font = font;
    }
    else {
        UIFont *font = [UIFont fontWithName:self.fonts[indexPath.row] size:NORMAL_SIZE_FONT.pointSize];
        cell.titleLabel.text = font.fontName;
        cell.titleLabel.font = font;
    }
    
    
    cell.iconImgView.hidden = ![[CacheManager shareCacheManager].danmakuFont.fontName isEqual:cell.titleLabel.font.fontName];
    
    return cell;
    
}

#pragma mark - 懒加载
- (BaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.allowScroll = YES;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 44;
        [_tableView registerClass:[FTPReceiceTableViewCell class] forCellReuseIdentifier:@"FTPReceiceTableViewCell"];
        
        @weakify(self)
        _tableView.mj_header = [MJRefreshNormalHeader jh_headerRefreshingCompletionHandler:^{
            @strongify(self)
            if (!self) return;
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableArray *fonts = [NSMutableArray array];
                NSArray<NSString *> *familyNames = [UIFont familyNames];
                [familyNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [fonts addObjectsFromArray:[UIFont fontNamesForFamilyName:obj]];
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
