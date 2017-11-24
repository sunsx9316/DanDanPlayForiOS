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
#import "TextHeaderView.h"
#import "DanmakuManager.h"

#import "JHSetting.h"
#import "UIFont+Tools.h"
#import "JHBaseTableView.h"
#import "LAContext+Tools.h"

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) JHBaseTableView *tableView;
@property (strong, nonatomic) NSArray <JHSetting *>*dataSources;
@end

@implementation SettingViewController
{
    NSString *_cacheSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    
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
    return CGFLOAT_MIN;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    JHSetting *item = self.dataSources[section];
    TextHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"TextHeaderView"];
    view.titleLabel.text = item.title;
    return view;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
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
- (JHBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[JHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[OtherSettingSwitchTableViewCell class] forCellReuseIdentifier:@"OtherSettingSwitchTableViewCell"];
        [_tableView registerClass:[OtherSettingTitleSubtitleTableViewCell class] forCellReuseIdentifier:@"OtherSettingTitleSubtitleTableViewCell"];
        [_tableView registerClass:[SettingTitleTableViewCell class] forCellReuseIdentifier:@"SettingTitleTableViewCell"];
        [_tableView registerClass:[TextHeaderView class] forHeaderFooterViewReuseIdentifier:@"TextHeaderView"];
        
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<JHSetting *> *)dataSources {
    if (_dataSources == nil) {
        
        //弹幕设置
        JHSetting *danmakuSetting = [[JHSetting alloc] init];
        danmakuSetting.title = @"弹幕设置";
        [danmakuSetting.items addObject:({
            JHSettingItem *item = [[JHSettingItem alloc] init];
            item.title = @"弹幕字体";
            item.type = JHSettingItemTypeDanmakuFont;
            [item setDetailTextCallBack:^{
                UIFont *font = [CacheManager shareCacheManager].danmakuFont;
                if (font.isSystemFont) {
                    return @"系统字体";
                }
                else {
                    return font.fontName;
                }
            }];
            item;
        })];
        
        [danmakuSetting.items addObject:({
            JHSettingItem *item = [[JHSettingItem alloc] init];
            item.title = @"弹幕屏蔽列表";
            item.type = JHSettingItemTypeFilter;
            item;
        })];
        
        [danmakuSetting.items addObject:({
            JHSettingItem *item = [[JHSettingItem alloc] init];
            item.title = @"弹幕快速匹配";
            item.detail = @"自动识别视频 并匹配弹幕";
            item.type = JHSettingItemTypeSwitch;
            [item setSwitchStatusCallBack:^{
                return [CacheManager shareCacheManager].openFastMatch;
            }];
            [item setSwitchStatusChangeCallBack:^{
                [CacheManager shareCacheManager].openFastMatch = ![CacheManager shareCacheManager].openFastMatch;
            }];
            item;
        })];
        
        [danmakuSetting.items addObject:({
            JHSettingItem *item = [[JHSettingItem alloc] init];
            item.title = @"自动请求第三方弹幕";
            item.detail = @"会把ABC站的弹幕一起加进来";
            item.type = JHSettingItemTypeSwitch;
            [item setSwitchStatusCallBack:^{
                return [CacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
            }];
            [item setSwitchStatusChangeCallBack:^{
                [CacheManager shareCacheManager].autoRequestThirdPartyDanmaku = ![CacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
            }];
            item;
        })];
        
        [danmakuSetting.items addObject:({
            JHSettingItem *item = [[JHSettingItem alloc] init];
            item.title = @"弹幕缓存时间";
            item.type = JHSettingItemTypeLeftRight;
            [item setDetailTextCallBack:^{
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
            item;
        })];
        
        
        //其他设置
        JHSetting *otherSetting = [[JHSetting alloc] init];
        otherSetting.title = @"其他设置";
        
        [otherSetting.items addObject:({
            JHSettingItem *item = [[JHSettingItem alloc] init];
            item.title = @"字幕保护区域";
            item.detail = @"在画面底部大约15%的位置禁止弹幕出现";
            item.type = JHSettingItemTypeSwitch;
            [item setSwitchStatusCallBack:^{
                return [CacheManager shareCacheManager].subtitleProtectArea;
            }];
            [item setSwitchStatusChangeCallBack:^{
                [CacheManager shareCacheManager].subtitleProtectArea = ![CacheManager shareCacheManager].subtitleProtectArea;
            }];
            item;
        })];
        
        [otherSetting.items addObject:({
            JHSettingItem *item = [[JHSettingItem alloc] init];
            item.title = @"自动加载远程设备字幕";
            item.detail = @"大概没人会关掉";
            item.type = JHSettingItemTypeSwitch;
            [item setSwitchStatusCallBack:^{
                return [CacheManager shareCacheManager].openAutoDownloadSubtitle;
            }];
            [item setSwitchStatusChangeCallBack:^{
                [CacheManager shareCacheManager].openAutoDownloadSubtitle = ![CacheManager shareCacheManager].openAutoDownloadSubtitle;
            }];
            item;
        })];
        
        LAContext *laContext = [[LAContext alloc] init];
        //验证touchID是否可用
        if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
            [otherSetting.items addObject:({
                NSString *biometryType = laContext.biometryTypeStringValue;
                
                JHSettingItem *item = [[JHSettingItem alloc] init];
                item.title = [NSString stringWithFormat:@"使用%@登录", biometryType];
                item.type = JHSettingItemTypeSwitch;
                @weakify(self)
                item.switchStatusCallBack = ^BOOL{
                    return [CacheManager shareCacheManager].useTouchIdLogin == UserLoginInTouchIdTypeReject ? NO : YES;
                };
                
                item.switchStatusChangeCallBack = ^{
                    @strongify(self)
                    if (!self) return;
                    
                    if ([CacheManager shareCacheManager].useTouchIdLogin == UserLoginInTouchIdTypeReject) {
                        [CacheManager shareCacheManager].useTouchIdLogin = UserLoginInTouchIdTypeAgree;
                    }
                    else {
                        [CacheManager shareCacheManager].useTouchIdLogin = UserLoginInTouchIdTypeReject;
                    }
                };
                item;
            })];            
        }
        
        [otherSetting.items addObject:({
            JHSettingItem *item = [[JHSettingItem alloc] init];
            item.title = @"清理缓存";
            item.type = JHSettingItemTypeLeftRight;
            @weakify(self)
            [item setDetailTextCallBack:^{
                @strongify(self)
                if (!self) return @"";
                
                return self->_cacheSize;
            }];
            item;
        })];
        
        _dataSources = @[danmakuSetting, otherSetting];
    }
    return _dataSources;
}

@end
