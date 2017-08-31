//
//  SettingViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "SettingViewController.h"
#import "DanmakuSelectedFontViewController.h"
#import "DanmakuFilterViewController.h"

#import "OtherSettingSwitchTableViewCell.h"
#import "OtherSettingTitleSubtitleTableViewCell.h"
#import "SettingTitleTableViewCell.h"
#import "SMBLoginHeaderView.h"
#import "DanmakuManager.h"

#import "JHSetting.h"
#import "UIFont+Tools.h"

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray <JHSetting *>*dataSources;
@end

@implementation SettingViewController
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
    
    JHSettingItem *item = self.dataSources[indexPath.section].items[indexPath.row];
    
    if (item.type == JHSettingItemTypeDanmakuFont) {
        DanmakuSelectedFontViewController *vc = [[DanmakuSelectedFontViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (item.type == JHSettingItemTypeFilter) {
        DanmakuFilterViewController *vc = [[DanmakuFilterViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (item.type == JHSettingItemTypeLeftRight) {
        if ([item.title isEqualToString:@"弹幕缓存时间"]) {
            UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"选择天数" message:@"默认7天" preferredStyle:UIAlertControllerStyleAlert];
            @weakify(vc)
            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                @strongify(vc)
                if (!vc) return;
                
                UITextField *textField = vc.textFields.firstObject;
                NSInteger day = [textField.text integerValue];
                if (day < 0) day = 0;
                if (day > CACHE_ALL_DANMAKU_FLAG) day = CACHE_ALL_DANMAKU_FLAG;
                
                [CacheManager shareCacheManager].danmakuCacheTime = day;
                [self.tableView reloadData];
            }]];
            
            [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            
            [self presentViewController:vc animated:YES completion:nil];
        }
        else if ([item.title isEqualToString:@"清理缓存"]) {
            [MBProgressHUD showLoadingInView:self.view text:@"删除中..."];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [DanmakuManager removeAllDanmakuCache];
                [CacheManager removeAllCache];
                [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
                [self reloadCacheSizeWithCompletion:^{
                    [MBProgressHUD hideLoading];
                    [self.tableView reloadData];
                }];
            });
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHSettingItem *item = self.dataSources[indexPath.section].items[indexPath.row];
    if (item.type == JHSettingItemTypeSwitch) {
        return 55;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    JHSetting *item = self.dataSources[section];
    SMBLoginHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"SMBLoginHeaderView"];
    view.titleLabel.text = item.title;
    view.addButton.hidden = YES;
    return view;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    if (section == 0) {
//        return 5;
//    }
//    return 2;
    return self.dataSources[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JHSettingItem *item = self.dataSources[indexPath.section].items[indexPath.row];
    if (item.type == JHSettingItemTypeDanmakuFont) {
        SettingTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingTitleTableViewCell" forIndexPath:indexPath];
            cell.titleLabel.text = item.title;
            UIFont *font = [CacheManager shareCacheManager].danmakuFont;
            cell.detailLabel.font = [font fontWithSize:NORMAL_SIZE_FONT.pointSize];
        cell.detailLabel.text = item.detailTextCallBack();
        return cell;
    }
    
    if (item.type == JHSettingItemTypeFilter) {
        SettingTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingTitleTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = item.title;
        return cell;
    }
    
    if (item.type == JHSettingItemTypeSwitch) {
        OtherSettingSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherSettingSwitchTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = item.title;
        cell.detailLabel.text = item.detail;
        cell.aSwitch.on = item.switchStatusCallBack();
        [cell setTouchSwitchCallBack:item.switchStatusChangeCallBack];
        return cell;
    }
    
    OtherSettingTitleSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OtherSettingTitleSubtitleTableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.titleLabel.text = item.title;
    cell.detailLabel.text = item.detailTextCallBack();
    return cell;
}

#pragma mark - 私有方法
- (void)reloadCacheSizeWithCompletion:(dispatch_block_t)completion {
    [[YYWebImageManager sharedManager].cache.diskCache totalCostWithBlock:^(NSInteger totalCost) {
        totalCost += [DanmakuManager danmakuCacheSize];
        totalCost += [CacheManager cacheSize];
        
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
        [_tableView registerClass:[OtherSettingSwitchTableViewCell class] forCellReuseIdentifier:@"OtherSettingSwitchTableViewCell"];
        [_tableView registerClass:[OtherSettingTitleSubtitleTableViewCell class] forCellReuseIdentifier:@"OtherSettingTitleSubtitleTableViewCell"];
        [_tableView registerClass:[SettingTitleTableViewCell class] forCellReuseIdentifier:@"SettingTitleTableViewCell"];
        [_tableView registerClass:[SMBLoginHeaderView class] forHeaderFooterViewReuseIdentifier:@"SMBLoginHeaderView"];
        
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<JHSetting *> *)dataSources {
    if (_dataSources == nil) {
        NSMutableArray *arr = [NSMutableArray array];
        
        //弹幕设置
        JHSetting *danmakuSetting = [[JHSetting alloc] init];
        danmakuSetting.title = @"弹幕设置";
        
        JHSettingItem *danmakuFontItem = [[JHSettingItem alloc] init];
        danmakuFontItem.title = @"弹幕字体";
        danmakuFontItem.type = JHSettingItemTypeDanmakuFont;
        [danmakuFontItem setDetailTextCallBack:^{
            UIFont *font = [CacheManager shareCacheManager].danmakuFont;
            if (font.isSystemFont) {
                return @"系统字体";
            }
            else {
                return font.fontName;
            }
        }];
        [danmakuSetting.items addObject:danmakuFontItem];
        
        JHSettingItem *danmakuFilterItem = [[JHSettingItem alloc] init];
        danmakuFilterItem.title = @"弹幕屏蔽列表";
        danmakuFilterItem.type = JHSettingItemTypeFilter;
        [danmakuSetting.items addObject:danmakuFilterItem];

        
        JHSettingItem *fastMatchItem = [[JHSettingItem alloc] init];
        fastMatchItem.title = @"弹幕快速匹配";
        fastMatchItem.detail = @"自动识别视频 并匹配弹幕";
        fastMatchItem.type = JHSettingItemTypeSwitch;
        [fastMatchItem setSwitchStatusCallBack:^{
            return [CacheManager shareCacheManager].openFastMatch;
        }];
        [fastMatchItem setSwitchStatusChangeCallBack:^{
            [CacheManager shareCacheManager].openFastMatch = ![CacheManager shareCacheManager].openFastMatch;
        }];
        [danmakuSetting.items addObject:fastMatchItem];
        
        JHSettingItem *requestThreePartyDamakuItem = [[JHSettingItem alloc] init];
        requestThreePartyDamakuItem.title = @"自动请求第三方弹幕";
        requestThreePartyDamakuItem.detail = @"会把ABC站的弹幕一起加进来";
        requestThreePartyDamakuItem.type = JHSettingItemTypeSwitch;
        [requestThreePartyDamakuItem setSwitchStatusCallBack:^{
            return [CacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
        }];
        [requestThreePartyDamakuItem setSwitchStatusChangeCallBack:^{
            [CacheManager shareCacheManager].autoRequestThirdPartyDanmaku = ![CacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
        }];
        [danmakuSetting.items addObject:requestThreePartyDamakuItem];
        
//        JHSettingItem *priorityLoadLocalDanmakuItem = [[JHSettingItem alloc] init];
//        priorityLoadLocalDanmakuItem.title = @"优先加载本地与视频同名的弹幕";
//        priorityLoadLocalDanmakuItem.detail = @"会替换掉网络弹幕";
//        priorityLoadLocalDanmakuItem.type = JHSettingItemTypeSwitch;
//        [priorityLoadLocalDanmakuItem setSwitchStatusCallBack:^{
//            return [CacheManager shareCacheManager].priorityLoadLocalDanmaku;
//        }];
//        [priorityLoadLocalDanmakuItem setSwitchStatusChangeCallBack:^{
//            [CacheManager shareCacheManager].priorityLoadLocalDanmaku = ![CacheManager shareCacheManager].priorityLoadLocalDanmaku;
//        }];
//        [danmakuSetting.items addObject:priorityLoadLocalDanmakuItem];
        
        JHSettingItem *danmakuCacheTimeItem = [[JHSettingItem alloc] init];
        danmakuCacheTimeItem.title = @"弹幕缓存时间";
        danmakuCacheTimeItem.type = JHSettingItemTypeLeftRight;
        [danmakuCacheTimeItem setDetailTextCallBack:^{
            NSInteger day = [CacheManager shareCacheManager].danmakuCacheTime;
            if (day == 0) {
                return @"不缓存";
            }
            else if (day >= CACHE_ALL_DANMAKU_FLAG) {
                return @"全部缓存";
            }
            else {
                return [NSString stringWithFormat:@"%ld天", (long)day];
            }
        }];
        [danmakuSetting.items addObject:danmakuCacheTimeItem];
        
        [arr addObject:danmakuSetting];
        
        
        //其他设置
        JHSetting *otherSetting = [[JHSetting alloc] init];
        otherSetting.title = @"其他设置";
        

        JHSettingItem *protectAreaItem = [[JHSettingItem alloc] init];
        protectAreaItem.title = @"字幕保护区域";
        protectAreaItem.detail = @"在画面底部大约15%的位置禁止弹幕出现";
        protectAreaItem.type = JHSettingItemTypeSwitch;
        [protectAreaItem setSwitchStatusCallBack:^{
            return [CacheManager shareCacheManager].subtitleProtectArea;
        }];
        [protectAreaItem setSwitchStatusChangeCallBack:^{
            [CacheManager shareCacheManager].subtitleProtectArea = ![CacheManager shareCacheManager].subtitleProtectArea;
        }];
        [otherSetting.items addObject:protectAreaItem];
        
        JHSettingItem *openAutoDownloadSubtitleItem = [[JHSettingItem alloc] init];
        openAutoDownloadSubtitleItem.title = @"自动加载远程设备字幕";
        openAutoDownloadSubtitleItem.detail = @"大概没人会关掉";
        openAutoDownloadSubtitleItem.type = JHSettingItemTypeSwitch;
        [openAutoDownloadSubtitleItem setSwitchStatusCallBack:^{
            return [CacheManager shareCacheManager].openAutoDownloadSubtitle;
        }];
        [openAutoDownloadSubtitleItem setSwitchStatusChangeCallBack:^{
            [CacheManager shareCacheManager].openAutoDownloadSubtitle = ![CacheManager shareCacheManager].openAutoDownloadSubtitle;
        }];
        [otherSetting.items addObject:openAutoDownloadSubtitleItem];
        
        JHSettingItem *showDownloadStatusViewItem = [[JHSettingItem alloc] init];
        showDownloadStatusViewItem.title = @"下载时显示状态图标";
        showDownloadStatusViewItem.detail = @"强迫症可以关掉";
        showDownloadStatusViewItem.type = JHSettingItemTypeSwitch;
        [showDownloadStatusViewItem setSwitchStatusCallBack:^{
            return [CacheManager shareCacheManager].showDownloadStatusView;
        }];
        [showDownloadStatusViewItem setSwitchStatusChangeCallBack:^{
            [CacheManager shareCacheManager].showDownloadStatusView = ![CacheManager shareCacheManager].showDownloadStatusView;
        }];
        [otherSetting.items addObject:showDownloadStatusViewItem];
        
        
        JHSettingItem *clearCacheItem = [[JHSettingItem alloc] init];
        clearCacheItem.title = @"清理缓存";
        clearCacheItem.type = JHSettingItemTypeLeftRight;
        @weakify(self)
        [clearCacheItem setDetailTextCallBack:^{
            @strongify(self)
            if (!self) return @"";
            
            return self->_cacheSize;
        }];
        [otherSetting.items addObject:clearCacheItem];
        [arr addObject:otherSetting];
        
        _dataSources = arr;
    }
    return _dataSources;
}

@end
