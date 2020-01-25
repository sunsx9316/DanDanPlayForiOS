//
//  DDPMainViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPMainViewController.h"
#import "DDPMineViewController.h"
#import "DDPNewHomePagePackageViewController.h"
#import "DDPBaseNavigationController.h"
#import "DDPMatchViewController.h"
#import "DDPTabBar.h"

#if !DDPAPPTYPEISMAC
#import "DDPFileViewController.h"
#else
#import "DDPDanmakuManager.h"
#import <DDPShare/DDPShare.h>
#import "DDPCommentNetManagerOperation.h"
#import "DDPDanmakuManager.h"
#import "DDPCacheManager+MacObserver.h"
#import "DDPGuildView.h"
#endif

@interface DDPMainViewController ()<UITabBarControllerDelegate, UIDropInteractionDelegate
#if DDPAPPTYPEISMAC
, DDPMessageManagerObserver
#endif
>

@property (nonatomic, strong) NSArray <NSString *>*registerTypes;
@end

@implementation DDPMainViewController {
#if DDPAPPTYPEISMAC
    NSArray <NSString *>*_addKeyPaths;
#endif
}

+ (NSArray<DDPMainVCItem *> *)items {
    static dispatch_once_t onceToken;
    static NSArray<DDPMainVCItem *>*_items = nil;
    dispatch_once(&onceToken, ^{
        let arr = [NSMutableArray array];
        if (ddp_appType != DDPAppTypeReview) {
            DDPMainVCItem *item = [[DDPMainVCItem alloc] init];
            item.normalImage = [UIImage imageNamed:@"main_bangumi"];
            item.selectedImage = [UIImage imageNamed:@"main_bangumi"];
            item.name = @"首页";
            item.vcClassName = [DDPNewHomePagePackageViewController className];
            [arr addObject:item];
        }
#if !DDPAPPTYPEISMAC
        {
            DDPMainVCItem *item = [[DDPMainVCItem alloc] init];
            item.normalImage = [UIImage imageNamed:@"main_file"];
            item.selectedImage = [UIImage imageNamed:@"main_file"];
            item.name = @"文件";
            item.vcClassName = [DDPFileViewController className];
            [arr addObject:item];
        }
#endif
        
        {
            DDPMainVCItem *item = [[DDPMainVCItem alloc] init];
            item.normalImage = [UIImage imageNamed:@"main_mine"];
            item.selectedImage = [UIImage imageNamed:@"main_mine"];
            item.name = @"我的";
            item.vcClassName = [DDPMineViewController className];
            [arr addObject:item];
        }
        
        _items = arr;
    });
    return _items;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (ddp_appType == DDPAppTypeToMac) {
            object_setClass(self.tabBar, [DDPTabBar class]);            
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    let items = [self.class items];
    let arr = [NSMutableArray arrayWithCapacity:items.count];
    
    [items enumerateObjectsUsingBlock:^(DDPMainVCItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UINavigationController *vc = [self navigationControllerWithNormalImg:obj.normalImage selectImg:obj.selectedImage rootVC:[[NSClassFromString(obj.vcClassName) alloc] init] title:nil];
        [arr addObject:vc];
    }];
    
    self.viewControllers = arr;
    
#if DDPAPPTYPEISMAC
    self.tabBar.alpha = 0;
    [[DDPMessageManager sharedManager] addObserver:self];
    [self addDragAndDrop];
    [self addNotice];
    
    if (!DDPCacheManager.shareCacheManager.guildViewIsShow) {
        DDPGuildView *view = [DDPGuildView fromXib];
        [self.view addSubview:view];
        [view show];
    }
#else
    self.tabBar.translucent = NO;
#endif
    
    [self renewToken];
    
    self.delegate = self;
}

- (BOOL)shouldAutorotate {
    return ddp_isPad();
}

//设置支持的屏幕旋转方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (ddp_isPad()) {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

//设置presentation方式展示的屏幕方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
#if !DDPAPPTYPE
    NSInteger index = [tabBarController.viewControllers indexOfObject:viewController];
    if (index == 2) {
        [[DDPDownloadManager shareDownloadManager] startObserverTaskInfo];
    }
    else {
        [[DDPDownloadManager shareDownloadManager] stopObserverTaskInfo];
    }
#endif
}

#pragma mark - UIDropInteractionDelegate
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session API_AVAILABLE(ios(11.0)){
    BOOL flag = [session hasItemsConformingToTypeIdentifiers:self.registerTypes];
    return flag;
}

- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session API_AVAILABLE(ios(11.0)) {
    
#if DDPAPPTYPEISMAC
    
    NSMutableArray <NSString *>*paths = [NSMutableArray arrayWithCapacity:session.items.count];
    NSMutableArray <NSString *>*danmakuPaths = [NSMutableArray arrayWithCapacity:session.items.count];
    
    let group = dispatch_group_create();
    let xmlType = (__bridge NSString *)kUTTypeXML;
    
    [session.items enumerateObjectsUsingBlock:^(UIDragItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        let itemProvider = obj.itemProvider;
        //弹幕和视频路径
        [self.registerTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj1, NSUInteger idx1, BOOL * _Nonnull stop1) {
            BOOL success = [itemProvider hasItemConformingToTypeIdentifier:obj1];
            if (success) {
                dispatch_group_enter(group);
                [itemProvider loadInPlaceFileRepresentationForTypeIdentifier:obj1 completionHandler:^(NSURL * _Nullable url, BOOL isInPlace, NSError * _Nullable error) {
                    if (url.path) {
                        //弹幕
                        if ([obj1 isEqualToString:xmlType]) {
                            [danmakuPaths addObject:url.path];
                        } else {
                            [paths addObject:url.path];
                        }
                        
                    }
                    
                    dispatch_group_leave(group);
                }];
            }
        }];
        
    }];
    
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (paths.count > 0) {
            DDPPlayerListMessage *message = [[DDPPlayerListMessage alloc] init];
            message.paths = paths;
            [[DDPMessageManager sharedManager] sendMessage:message];
        }
        
        if (danmakuPaths.count > 0) {
            [self sendLoadLocalDanmakuMessageWithPaths:danmakuPaths];
        }
    });
#endif
}

- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session API_AVAILABLE(ios(11.0)) {
    let dropLocation = [session locationInView:self.view];
    UIDropOperation operation = UIDropOperationCancel;
    
    if (CGRectContainsPoint(self.view.frame, dropLocation)) {
        operation = session.localDragSession == nil ? UIDropOperationCopy : UIDropOperationMove;
    }
    return [[UIDropProposal alloc] initWithDropOperation:operation];
}

#if DDPAPPTYPEISMAC
#pragma mark - DDPMessageManagerObserver
- (void)dispatchManager:(DDPMessageManager *)manager didReceiveMessages:(NSArray <id<DDPMessageProtocol>>*)messages {
    for (id<DDPMessageProtocol> message in messages) {
        if ([message.messageType isEqualToString:DDPParseMessage.messageType]) {
            DDPParseMessage *aMessage = [[DDPParseMessage alloc] initWithObj:message];
            NSURL *url = [NSURL fileURLWithPath:aMessage.path];
            
            [self parseWithURL:url completion:^(DDPDanmakuCollection *collection, NSError *error) {
                if (DDPCacheManager.shareCacheManager.loadLocalDanmaku) {
                    let subtitleURL = [DDPToolsManager subTitleFileWithLocalURL:url].firstObject;
                    if (subtitleURL) {
                        [self sendLoadLocalDanmakuMessageWithPaths:@[subtitleURL.path]];
                    }
                }
            }];
        } else if ([message.messageType isEqualToString:DDPDanmakuSettingMessage.messageType]) {
            [DDPMethod sendConfigMessage];
        } else if ([message.messageType isEqualToString:DDPSendDanmakuMessage.messageType]) {
            DDPSendDanmakuMessage *aMessage = [[DDPSendDanmakuMessage alloc] initWithObj:message];
            
            let episodeId = aMessage.episodeId;
            DDPDanmaku *danmaku = (DDPDanmaku *)aMessage.danmaku;
            
            [DDPCommentNetManagerOperation launchDanmakuWithModel:danmaku episodeId:episodeId completionHandler:^(NSError *error) {
                if (error) {
                    aMessage.danmaku = nil;
                    [[DDPMessageManager sharedManager] sendMessage:aMessage];
                }
                else {
                    [[DDPMessageManager sharedManager] sendMessage:aMessage];
                    
                    //发送成功 缓存弹幕
                    NSMutableArray <DDPDanmaku *>*danmakus = [DDPDanmakuManager danmakuCacheWithEpisodeId:episodeId source:DDPDanmakuTypeByUser].mutableCopy;
                    [danmakus addObject:danmaku];
                    
                    [DDPDanmakuManager saveDanmakuWithObj:danmakus episodeId:episodeId source:DDPDanmakuTypeByUser];
                }
            }];
        }
    }
}
#endif

#pragma mark - 私有方法

- (void)renewToken {
    let user = DDPCacheManager.shareCacheManager.currentUser;
    //当前未登录 不请求
    if (user.isLogin == NO) {
        return;
    }
    //启动时默认为登出状态 强制请求token
    [user updateLoginStatus:NO];
    [DDPLoginNetManagerOperation renewWithCompletionHandler:^(DDPUser *model, NSError *error) {
        if (model) {
            DDPCacheManager.shareCacheManager.currentUser = model;
        } else {
            [self.view showWithError:error];
        }
    }];
}

- (UINavigationController *)navigationControllerWithNormalImg:(UIImage *)normalImg selectImg:(UIImage *)selectImg rootVC:(UIViewController *)rootVC title:(NSString *)title {
    
    normalImg = [normalImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    selectImg = [[selectImg imageByTintColor:[UIColor ddp_mainColor]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title
                                                       image:normalImg
                                               selectedImage:selectImg];
    UINavigationController *navVC = [[DDPBaseNavigationController alloc] initWithRootViewController:rootVC];
    navVC.tabBarItem = item;
    if (ddp_isPad() == NO) {
        item.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0);
    }
    
    return navVC;
}

- (void)addDragAndDrop {
    if (@available(iOS 11.0, *)) {
        let dropInteraction = [[UIDropInteraction alloc] initWithDelegate:self];
        [self.view addInteraction:dropInteraction];
    }
}

#if DDPAPPTYPEISMAC
- (void)addNotice {
    
    _addKeyPaths = DDPCacheManager.shareCacheManager.dynamicChangeKeys;
    
    [_addKeyPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[DDPCacheManager shareCacheManager] addObserver:self forKeyPath:obj options:NSKeyValueObservingOptionNew context:nil];
    }];
}

- (void)dealloc {
    [_addKeyPaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[DDPCacheManager shareCacheManager] removeObserver:self forKeyPath:obj];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([_addKeyPaths containsObject:keyPath]) {
        let message = [[DDPDanmakuSettingMessage alloc] init];
        let dic = [NSMutableDictionary dictionary];
        dic[keyPath] = change[NSKeyValueChangeNewKey];
        
        [message yy_modelSetWithDictionary:dic];
        [[DDPMessageManager sharedManager] sendMessage:message];
    }
}

- (void)sendLoadLocalDanmakuMessageWithPaths:(NSArray <NSString *>*)danmakuPaths {
    let data = [[NSData alloc] initWithContentsOfFile:danmakuPaths.firstObject];
    if (data) {
        DDPLoalLocalDanmakuMessage *msg = [[DDPLoalLocalDanmakuMessage alloc] init];
        let damakus = [DDPDanmakuManager parseLocalDanmakuToArrayWithSource:DDPDanmakuTypeBiliBili obj:data];
        msg.danmaku = damakus;
        [[DDPMessageManager sharedManager] sendMessage:msg];
    }
}
#endif

- (void)parseWithURL:(NSURL *)url completion:(DDPFastMatchAction)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        DDPFile *file = [[DDPFile alloc] initWithFileURL:url type:DDPFileTypeDocument];
        [DDPMethod matchFile:file completion:completion];
    });
}

- (NSArray<NSString *> *)registerTypes {
    if (_registerTypes == nil) {
        _registerTypes = @[(__bridge NSString *)kUTTypeMovie, (__bridge NSString *)kUTTypeFolder, (__bridge NSString *)kUTTypeXML];
    }
    return _registerTypes;
}

@end
