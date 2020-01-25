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

#if DDPAPPTYPEISMAC
#import "DDPPlayerConfigPanelViewController.h"
#endif

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
    
    [[DDPCacheManager shareCacheManager] addObserver:self forKeyPath:DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuFont) options:NSKeyValueObservingOptionNew context:nil];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self reloadCacheSizeWithCompletion:^{
        [self.tableView reloadData];
    }];
}

- (void)dealloc {
    [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuFont)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:DDP_KEYPATH([DDPCacheManager shareCacheManager], danmakuFont)]) {
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DDPSettingItem *item = self.dataSources[indexPath.section].items[indexPath.row];
    
    if (item.didSelectedCellCallBack) {
        item.didSelectedCellCallBack(indexPath);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPSettingItem *item = self.dataSources[indexPath.section].items[indexPath.row];
    if (item.reuseClass == [DDPOtherSettingSwitchTableViewCell class]) {
        return 70;
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(item.reuseClass) forIndexPath:indexPath];
    if (item.dequeueReuseCellCallBack) {
        item.dequeueReuseCellCallBack(cell);
    }
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
        [_tableView registerClass:[DDPOtherSettingSwitchTableViewCell class] forCellReuseIdentifier:[DDPOtherSettingSwitchTableViewCell className]];
        [_tableView registerClass:[DDPOtherSettingTitleSubtitleTableViewCell class] forCellReuseIdentifier:[DDPOtherSettingTitleSubtitleTableViewCell className]];
        [_tableView registerClass:[DDPSettingTitleTableViewCell class] forCellReuseIdentifier:[DDPSettingTitleTableViewCell className]];
        [_tableView registerClass:[DDPTextHeaderView class] forHeaderFooterViewReuseIdentifier:[DDPTextHeaderView className]];
        
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
        _tableView.tableFooterView = [[UIView alloc] init];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSArray<DDPSetting *> *)dataSources {
    if (_dataSources == nil) {
        NSMutableArray <DDPSetting *>*arr = [NSMutableArray arrayWithCapacity:3];
        
        @weakify(self)
        #if DDPAPPTYPEISMAC
        DDPSetting *playerSetting = [[DDPSetting alloc] init];
        playerSetting.title = @"播放设置";
        [playerSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPSettingTitleTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPOtherSettingTitleSubtitleTableViewCell *cell) {
                cell.titleLabel.text = @"播放器设置";
            };
            
            item.didSelectedCellCallBack = ^(NSIndexPath *indexPath) {
                @strongify(self)
                if (!self) return;
                
                let vc = [[DDPPlayerConfigPanelViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            };
            
            return item;
        }()];
        
        [arr addObject:playerSetting];
        #endif
        
        //弹幕设置
        DDPSetting *danmakuSetting = [[DDPSetting alloc] init];
        [arr addObject:danmakuSetting];
        danmakuSetting.title = @"弹幕设置";
        [danmakuSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPSettingTitleTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPSettingTitleTableViewCell *cell) {
                cell.titleLabel.text = @"弹幕字体";
                UIFont *font = [DDPCacheManager shareCacheManager].danmakuFont;
                cell.detailLabel.font = [font fontWithSize:[UIFont ddp_normalSizeFont].pointSize];
                
                if (font.isSystemFont) {
                    cell.detailLabel.text = @"系统字体";
                }
                else {
                    cell.detailLabel.text = font.fontName;
                }
            };
            
            item.didSelectedCellCallBack = ^(NSIndexPath *indexPath) {
                @strongify(self)
                if (!self) return;
                
                DDPDanmakuSelectedFontViewController *vc = [[DDPDanmakuSelectedFontViewController alloc] init];
                vc.hidesBottomBarWhenPushed = true;
                [self.navigationController pushViewController:vc animated:YES];
            };
            
            return item;
        }()];
        
        
        [danmakuSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPSettingTitleTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPSettingTitleTableViewCell *cell) {
                cell.titleLabel.text = @"弹幕屏蔽列表";
            };
            
            item.didSelectedCellCallBack = ^(NSIndexPath *indexPath) {
                @strongify(self)
                if (!self) return;
                
                DDPDanmakuFilterViewController *vc = [[DDPDanmakuFilterViewController alloc] init];
                vc.hidesBottomBarWhenPushed = true;
                [self.navigationController pushViewController:vc animated:YES];
            };
            
            return item;
        }()];
        
#if !DDPAPPTYPEISREVIEW
        [danmakuSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPOtherSettingSwitchTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPOtherSettingSwitchTableViewCell *cell) {
                cell.titleLabel.text = @"弹幕快速匹配";
                cell.detailLabel.text = @"自动识别视频 并匹配弹幕";
                cell.aSwitch.on = [DDPCacheManager shareCacheManager].openFastMatch;
                cell.touchSwitchCallBack = ^(UISwitch *aSwitch) {
                    [DDPCacheManager shareCacheManager].openFastMatch = ![DDPCacheManager shareCacheManager].openFastMatch;
                };
            };
            return item;
        }()];
        
        [danmakuSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPOtherSettingSwitchTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPOtherSettingSwitchTableViewCell *cell) {
                cell.titleLabel.text = @"自动请求第三方弹幕";
                cell.detailLabel.text = @"会把ABC站的弹幕一起加进来";
                cell.aSwitch.on = [DDPCacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
                cell.touchSwitchCallBack = ^(UISwitch *aSwitch) {
                    [DDPCacheManager shareCacheManager].autoRequestThirdPartyDanmaku = ![DDPCacheManager shareCacheManager].autoRequestThirdPartyDanmaku;
                };
            };
            return item;
        }()];
#endif
        
        [danmakuSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPOtherSettingTitleSubtitleTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPOtherSettingTitleSubtitleTableViewCell *cell) {
                cell.titleLabel.text = @"弹幕缓存时间";
                NSInteger day = [DDPCacheManager shareCacheManager].danmakuCacheTime;
                if (day == 0) {
                    cell.detailLabel.text = @"不缓存";
                }
                else if (day >= CACHE_ALL_DANMAKU_FLAG) {
                    cell.detailLabel.text = @"全部缓存";
                }
                else {
                    cell.detailLabel.text = [NSString stringWithFormat:@"%ld天", (long)day];
                }
            };
            
            item.didSelectedCellCallBack = ^(NSIndexPath *indexPath) {
                @strongify(self)
                if (!self) return;
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"设置天数" message:@"默认7天" preferredStyle:UIAlertControllerStyleAlert];
                @weakify(vc)
                [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                
                [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    @strongify(vc)
                    @strongify(self)
                    if (!self) return;
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
            };
            
            return item;
        }()];
        
        
        //其他设置
        DDPSetting *otherSetting = [[DDPSetting alloc] init];
        [arr addObject:otherSetting];
        otherSetting.title = @"其他设置";
        
        [otherSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPOtherSettingSwitchTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPOtherSettingSwitchTableViewCell *cell) {
                cell.titleLabel.text = @"字幕保护区域";
                cell.detailLabel.text = @"在画面底部大约15%的位置禁止弹幕出现";
                cell.aSwitch.on = [DDPCacheManager shareCacheManager].subtitleProtectArea;
                cell.touchSwitchCallBack = ^(UISwitch *aSwitch) {
                    [DDPCacheManager shareCacheManager].subtitleProtectArea = ![DDPCacheManager shareCacheManager].subtitleProtectArea;
                };
            };
            return item;
        }()];
        
        [otherSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPOtherSettingSwitchTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPOtherSettingSwitchTableViewCell *cell) {
                cell.titleLabel.text = @"自动加载同名弹幕";
                cell.detailLabel.text = @"目前支持 XML 格式弹幕";
                cell.aSwitch.on = [DDPCacheManager shareCacheManager].loadLocalDanmaku;
                cell.touchSwitchCallBack = ^(UISwitch *aSwitch) {
                    [DDPCacheManager shareCacheManager].loadLocalDanmaku = ![DDPCacheManager shareCacheManager].loadLocalDanmaku;
                };
            };
            return item;
        }()];

#if DDPAPPTYPEIOS
        [otherSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPOtherSettingSwitchTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPOtherSettingSwitchTableViewCell *cell) {
                cell.titleLabel.text = @"自动加载局域网设备字幕";
                cell.detailLabel.text = @"大概没人会关掉";
                cell.aSwitch.on = [DDPCacheManager shareCacheManager].openAutoDownloadSubtitle;
                cell.touchSwitchCallBack = ^(UISwitch *aSwitch) {
                    [DDPCacheManager shareCacheManager].openAutoDownloadSubtitle = ![DDPCacheManager shareCacheManager].openAutoDownloadSubtitle;
                };
            };
            return item;
        }()];
#endif
        
        LAContext *laContext = [[LAContext alloc] init];
        //验证touchID是否可用
        if ([laContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
            [otherSetting.items addObject:^{
                NSString *biometryType = laContext.biometryTypeStringValue;
                
                DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPOtherSettingSwitchTableViewCell class]];
                item.dequeueReuseCellCallBack = ^(DDPOtherSettingSwitchTableViewCell *cell) {
                    cell.titleLabel.text = [NSString stringWithFormat:@"使用%@登录", biometryType];
                    cell.aSwitch.on = [DDPCacheManager shareCacheManager].useTouchIdLogin;
                    cell.touchSwitchCallBack = ^(UISwitch *aSwitch) {
                        [DDPCacheManager shareCacheManager].useTouchIdLogin = ![DDPCacheManager shareCacheManager].useTouchIdLogin;
                    };
                };
                
                return item;
            }()];
        }
        
        [otherSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPOtherSettingTitleSubtitleTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPOtherSettingTitleSubtitleTableViewCell *cell) {
                cell.titleLabel.text = @"请求域名";
                NSString *domain = [DDPCacheManager shareCacheManager].userDefineRequestDomain;
                cell.detailLabel.text = domain.length > 0 ? domain : @"默认";
            };
            
            item.didSelectedCellCallBack = ^(NSIndexPath *indexPath) {
                @strongify(self)
                if (!self) return;
                
                UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"输入请求域名" message:@"留空则使用默认域名" preferredStyle:UIAlertControllerStyleAlert];
                @weakify(vc)
                [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    @strongify(vc)
                    if (!vc) return;
                    
                    NSString *domain = vc.textFields.firstObject.text;
                    [DDPCacheManager shareCacheManager].userDefineRequestDomain = domain;
                    [self.tableView reloadData];
                }]];
                
                [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
                
                [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                    textField.text = [DDPCacheManager shareCacheManager].userDefineRequestDomain;
                    textField.font = [UIFont ddp_normalSizeFont];
                    textField.placeholder = @"例如: https://api.acplay.net";
                }];
                
                [self presentViewController:vc animated:true completion:nil];
            };
            
            return item;
        }()];
        
        [otherSetting.items addObject:^{
            DDPSettingItem *item = [[DDPSettingItem alloc] initWithReuseClass:[DDPOtherSettingTitleSubtitleTableViewCell class]];
            item.dequeueReuseCellCallBack = ^(DDPOtherSettingTitleSubtitleTableViewCell *cell) {
                @strongify(self)
                if (!self) return;
                
                cell.titleLabel.text = @"清理弹幕、图片缓存";
                cell.detailLabel.text = self->_cacheSize;
            };
            
            item.didSelectedCellCallBack = ^(NSIndexPath *indexPath) {
                @strongify(self)
                if (!self) return;
                
                [self.view showLoadingWithText:@"删除中..."];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    @strongify(self)
                    if (!self) return;
                    
                    [DDPDanmakuManager removeAllDanmakuCache];
                    [[YYWebImageManager sharedManager].cache.diskCache removeAllObjects];
                    [self reloadCacheSizeWithCompletion:^{
                        @strongify(self)
                        if (!self) return;
                        
                        [self.view hideLoading];
                        [self.tableView reloadData];
                    }];
                });
            };
            
            return item;
        }()];
        
        _dataSources = arr;
    }
    return _dataSources;
}

@end
