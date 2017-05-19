//
//  OtherSettingViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "OtherSettingViewController.h"
//#import "MatchTableViewCell.h"
#import "OtherSettingSwitchTableViewCell.h"
#import "OtherSettingTitleSubtitleTableViewCell.h"
#import "DanmakuManager.h"

@interface OtherSettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation OtherSettingViewController
{
    NSString *_cacheSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cacheSize = @"计算中";
    
    [[CacheManager shareCacheManager] addObserver:self forKeyPath:@"danmakuFont" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self reloadCacheSizeWithCompletion:^{
        [self.tableView reloadData];
    }];
}

- (void)dealloc {
    [[CacheManager shareCacheManager] removeObserver:self forKeyPath:@"danmakuFont"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"danmakuFont"]) {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 3) {
        
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"选择天数" message:@"默认7天" preferredStyle:UIAlertControllerStyleAlert];
        @weakify(vc)
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(vc)
            if (!vc) return;
            
            UITextField *textField = vc.textFields.firstObject;
            [CacheManager shareCacheManager].danmakuCacheTime = [textField.text integerValue];
            [self.tableView reloadRow:3 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
        }]];
        
        [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        [self presentViewController:vc animated:YES completion:nil];
    }
    else if (indexPath.row == 4) {
        [MBProgressHUD showIndeterminateHUDWithView:self.view text:@"删除中..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [DanmakuManager removeAllDanmakuCache];
            [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
            [self reloadCacheSizeWithCompletion:^{
                [MBProgressHUD hideIndeterminateHUD];
                [self.tableView reloadRow:4 inSection:0 withRowAnimation:UITableViewRowAnimationNone];
            }];
        });
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        return 55;
    }
    return 44;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 3) {
        OtherSettingSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherSettingSwitchTableViewCell" forIndexPath:indexPath];
        
        if (indexPath.row == 0) {
            cell.titleLabel.text = @"弹幕快速匹配";
            cell.detailLabel.text = @"自动识别视频 并匹配弹幕";
            cell.aSwitch.on = [CacheManager shareCacheManager].openFastMatch;
            [cell setTouchSwitchCallBack:^{
                [CacheManager shareCacheManager].openFastMatch = ![CacheManager shareCacheManager].openFastMatch;
            }];
        }
        else if (indexPath.row == 1) {
            cell.titleLabel.text = @"字幕保护区域";
            cell.detailLabel.text = @"在画面底部大约15%的位置禁止弹幕出现";
            cell.aSwitch.on = [CacheManager shareCacheManager].subtitleProtectArea;
            [cell setTouchSwitchCallBack:^{
                [CacheManager shareCacheManager].subtitleProtectArea = ![CacheManager shareCacheManager].subtitleProtectArea;
            }];
        }
        else if (indexPath.row == 2) {
            cell.titleLabel.text = @"自动请求第三方弹幕";
            cell.detailLabel.text = @"会把ABC站的弹幕也一起加进来";
            cell.aSwitch.on = [CacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
            [cell setTouchSwitchCallBack:^{
                [CacheManager shareCacheManager].autoRequestThirdPartyDanmaku = ![CacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
            }];
        }
        
        return cell;
    }
    
    
    OtherSettingTitleSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherSettingTitleSubtitleTableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    if (indexPath.row == 3) {
        cell.titleLabel.text = @"弹幕缓存时间";
        NSInteger day = [CacheManager shareCacheManager].danmakuCacheTime;
        if (day == 0) {
            cell.detailLabel.text = @"不缓存";
        }
        else {
            cell.detailLabel.text = [NSString stringWithFormat:@"%ld天", (long)day];
        }
    }
    else {
        cell.titleLabel.text = @"清除缓存";
        cell.detailLabel.text = _cacheSize;
    }
    return cell;
}

#pragma mark - 私有方法
- (void)reloadCacheSizeWithCompletion:(dispatch_block_t)completion {
    [[YYWebImageManager sharedManager].cache.diskCache totalCostWithBlock:^(NSInteger totalCost) {
        totalCost += [DanmakuManager danmakuCacheSize];
        
        float cache = totalCost / 1000.0;
        
        //大于1M
        if (cache > 1000) {
            _cacheSize = [NSString stringWithFormat:@"%.1fM", cache / 1000];
        }
        else {
            _cacheSize = [NSString stringWithFormat:@"%.1fK", cache];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion();
            }
        });
    }];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"OtherSettingSwitchTableViewCell" bundle:nil] forCellReuseIdentifier:@"OtherSettingSwitchTableViewCell"];
        [_tableView registerClass:[OtherSettingTitleSubtitleTableViewCell class] forCellReuseIdentifier:@"OtherSettingTitleSubtitleTableViewCell"];
        
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}


@end
