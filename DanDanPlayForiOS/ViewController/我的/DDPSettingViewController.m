//
//  DDPSettingViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPSettingViewController.h"
#import "DDPDanmakuSelectedFontViewController.h"
#import "DDPDanmakuFilterViewController.h"

#import "DDPOtherSettingSwitchTableViewCell.h"
#import "DDPOtherSettingTitleSubtitleTableViewCell.h"
#import "DDPSettingTitleTableViewCell.h"
#import "DDPTextHeaderView.h"
#import "DDPDanmakuManager.h"

#import "DDPSetting.h"
#import "UIFont+Tools.h"
#import "DDPBaseTableView.h"
#import "LAContext+Tools.h"

@interface DDPSettingViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) DDPBaseTableView *tableView;
@property (strong, nonatomic) NSArray <DDPSetting *>*dataSources;
@end

@implementation DDPSettingViewController
{
    NSString *_cacheSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"设置";
    
    _cacheSize = @"计算中";
    
    [[DDPCacheManager shareCacheManager] addObserver:self forKeyPath:@"danmakuFont" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self reloadCacheSizeWithCompletion:^{
        [self.tableView reloadData];
    }];
}

- (void)dealloc {
    [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:@"danmakuFont"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"danmakuFont"]) {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DDPSettingItem *item = self.dataSources[indexPath.section].items[indexPath.row];
    
    if (item.type == DDPSettingItemTypeDanmakuFont) {
        DDPDanmakuSelectedFontViewController *vc = [[DDPDanmakuSelectedFontViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (item.type == DDPSettingItemTypeFilter) {
        DDPDanmakuFilterViewController *vc = [[DDPDanmakuFilterViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if (item.type == DDPSettingItemTypeLeftRight) {
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
                
                [DDPCacheManager shareCacheManager].danmakuCacheTime = day;
                [self.tableView reloadData];
            }]];
            
            [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            
            [self presentViewController:vc animated:YES completion:nil];
        }
        else if ([item.title isEqualToString:@"清理缓存"]) {
            [self.view showLoadingWithText:@"删除中..."];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [DDPDanmakuManager removeAllDanmakuCache];
//                [DDPCacheManager removeAllCache];
                [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
                [self reloadCacheSizeWithCompletion:^{
                    [self.view hideLoading];
                    [self.tableView reloadData];
                }];
            });
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPSettingItem *item = self.dataSources[indexPath.section].items[indexPath.row];
    if (item.type == DDPSettingItemTypeSwitch) {
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
    DDPSetting *item = self.dataSources[section];
    DDPTextHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"DDPTextHeaderView"];
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
    DDPSettingItem *item = self.dataSources[indexPath.section].items[indexPath.row];
    if (item.type == DDPSettingItemTypeDanmakuFont) {
        DDPSettingTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPSettingTitleTableViewCell" forIndexPath:indexPath];
            cell.titleLabel.text = item.title;
            UIFont *font = [DDPCacheManager shareCacheManager].danmakuFont;
            cell.detailLabel.font = [font fontWithSize:[UIFont ddp_normalSizeFont].pointSize];
        cell.detailLabel.text = item.detailTextCallBack();
        return cell;
    }
    
    if (item.type == DDPSettingItemTypeFilter) {
        DDPSettingTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPSettingTitleTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = item.title;
        return cell;
    }
    
    if (item.type == DDPSettingItemTypeSwitch) {
        DDPOtherSettingSwitchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPOtherSettingSwitchTableViewCell" forIndexPath:indexPath];
        cell.titleLabel.text = item.title;
        cell.detailLabel.text = item.detail;
        cell.aSwitch.on = item.switchStatusCallBack();
        [cell setTouchSwitchCallBack:item.switchStatusChangeCallBack];
        return cell;
    }
    
    DDPOtherSettingTitleSubtitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPOtherSettingTitleSubtitleTableViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    cell.titleLabel.text = item.title;
    cell.detailLabel.text = item.detailTextCallBack();
    return cell;
}

#pragma mark - 私有方法
- (void)reloadCacheSizeWithCompletion:(dispatch_block_t)completion {
    [[YYWebImageManager sharedManager].cache.diskCache totalCostWithBlock:^(NSInteger totalCost) {
        totalCost += [DDPDanmakuManager danmakuCacheSize];
//        totalCost += [DDPCacheManager cacheSize];
        
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
- (DDPBaseTableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[DDPBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[DDPOtherSettingSwitchTableViewCell class] forCellReuseIdentifier:@"DDPOtherSettingSwitchTableViewCell"];
        [_tableView registerClass:[DDPOtherSettingTitleSubtitleTableViewCell class] forCellReuseIdentifier:@"DDPOtherSettingTitleSubtitleTableViewCell"];
        [_tableView registerClass:[DDPSettingTitleTableViewCell class] forCellReuseIdentifier:@"DDPSettingTitleTableViewCell"];
        [_tableView registerClass:[DDPTextHeaderView class] forHeaderFooterViewReuseIdentifier:@"DDPTextHeaderView"];
        
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<DDPSetting *> *)dataSources {
    if (_dataSources == nil) {
        
        //弹幕设置
        DDPSetting *danmakuSetting = [[DDPSetting alloc] init];
        danmakuSetting.title = @"弹幕设置";
        danmakuSetting.items = @[({
            DDPSettingItem *item = [[DDPSettingItem alloc] init];
            item.title = @"弹幕字体";
            item.type = DDPSettingItemTypeDanmakuFont;
            [item setDetailTextCallBack:^{
                UIFont *font = [DDPCacheManager shareCacheManager].danmakuFont;
                if (font.isSystemFont) {
                    return @"系统字体";
                }
                else {
                    return font.fontName;
                }
            }];
            item;
        }), ({
            DDPSettingItem *item = [[DDPSettingItem alloc] init];
            item.title = @"弹幕屏蔽列表";
            item.type = DDPSettingItemTypeFilter;
            item;
        }), ({
            DDPSettingItem *item = [[DDPSettingItem alloc] init];
            item.title = @"弹幕快速匹配";
            item.detail = @"自动识别视频 并匹配弹幕";
            item.type = DDPSettingItemTypeSwitch;
            [item setSwitchStatusCallBack:^{
                return [DDPCacheManager shareCacheManager].openFastMatch;
            }];
            [item setSwitchStatusChangeCallBack:^{
                [DDPCacheManager shareCacheManager].openFastMatch = ![DDPCacheManager shareCacheManager].openFastMatch;
            }];
            item;
        }), ({
            DDPSettingItem *item = [[DDPSettingItem alloc] init];
            item.title = @"自动请求第三方弹幕";
            item.detail = @"会把ABC站的弹幕一起加进来";
            item.type = DDPSettingItemTypeSwitch;
            [item setSwitchStatusCallBack:^{
                return [DDPCacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
            }];
            [item setSwitchStatusChangeCallBack:^{
                [DDPCacheManager shareCacheManager].autoRequestThirdPartyDanmaku = ![DDPCacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
            }];
            item;
        }), ({
            DDPSettingItem *item = [[DDPSettingItem alloc] init];
            item.title = @"弹幕缓存时间";
            item.type = DDPSettingItemTypeLeftRight;
            [item setDetailTextCallBack:^{
                NSInteger day = [DDPCacheManager shareCacheManager].danmakuCacheTime;
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
        })].mutableCopy;
        
        
        //其他设置
        DDPSetting *otherSetting = [[DDPSetting alloc] init];
        otherSetting.title = @"其他设置";
        
        [otherSetting.items addObject:({
            DDPSettingItem *item = [[DDPSettingItem alloc] init];
            item.title = @"字幕保护区域";
            item.detail = @"在画面底部大约15%的位置禁止弹幕出现";
            item.type = DDPSettingItemTypeSwitch;
            [item setSwitchStatusCallBack:^{
                return [DDPCacheManager shareCacheManager].subtitleProtectArea;
            }];
            [item setSwitchStatusChangeCallBack:^{
                [DDPCacheManager shareCacheManager].subtitleProtectArea = ![DDPCacheManager shareCacheManager].subtitleProtectArea;
            }];
            item;
        })];
        
        [otherSetting.items addObject:({
            DDPSettingItem *item = [[DDPSettingItem alloc] init];
            item.title = @"自动加载远程设备字幕";
            item.detail = @"大概没人会关掉";
            item.type = DDPSettingItemTypeSwitch;
            [item setSwitchStatusCallBack:^{
                return [DDPCacheManager shareCacheManager].openAutoDownloadSubtitle;
            }];
            [item setSwitchStatusChangeCallBack:^{
                [DDPCacheManager shareCacheManager].openAutoDownloadSubtitle = ![DDPCacheManager shareCacheManager].openAutoDownloadSubtitle;
            }];
            item;
        })];
        
        LAContext *laContext = [[LAContext alloc] init];
        //验证touchID是否可用
        if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
            [otherSetting.items addObject:({
                NSString *biometryType = laContext.biometryTypeStringValue;
                
                DDPSettingItem *item = [[DDPSettingItem alloc] init];
                item.title = [NSString stringWithFormat:@"使用%@登录", biometryType];
                item.type = DDPSettingItemTypeSwitch;
                item.switchStatusCallBack = ^BOOL{
                    return [DDPCacheManager shareCacheManager].useTouchIdLogin;
                };
                
                item.switchStatusChangeCallBack = ^{
                    [DDPCacheManager shareCacheManager].useTouchIdLogin = ![DDPCacheManager shareCacheManager].useTouchIdLogin;
                };
                item;
            })];            
        }
        
        [otherSetting.items addObject:({
            DDPSettingItem *item = [[DDPSettingItem alloc] init];
            item.title = @"清理缓存";
            item.type = DDPSettingItemTypeLeftRight;
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
