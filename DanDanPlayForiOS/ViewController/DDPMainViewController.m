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
#import <DDPShare/DDPShare.h>
#import "DDPCommentNetManagerOperation.h"
#import "DDPDanmakuManager.h"
#endif

@interface DDPMainViewController ()<UITabBarControllerDelegate, UIDropInteractionDelegate
#if DDPAPPTYPEISMAC
, DDPMessageManagerObserver
#endif
>
@end

@implementation DDPMainViewController

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
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
#endif
    
#if DDPAPPTYPEISMAC
        self.tabBar.alpha = 0;
        [[DDPMessageManager sharedManager] addObserver:self];
        [self addDragAndDrop];
#else
        self.tabBar.translucent = NO;
#endif
    
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
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session {
    BOOL flag = [session hasItemsConformingToTypeIdentifiers:@[(__bridge NSString *)kUTTypeMovie]];
    return flag;
}

- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session {
    [session.items.firstObject.itemProvider loadInPlaceFileRepresentationForTypeIdentifier:(__bridge NSString *)kUTTypeMovie completionHandler:^(NSURL * _Nullable url, BOOL isInPlace, NSError * _Nullable error) {
        [self parseWithURL:url];
    }];
}

- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session {
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
            [self parseWithURL:url];
        } else if ([message.messageType isEqualToString:DDPDanmakuSettingMessage.messageType]) {
            DDPDanmakuSettingMessage *aMessage = [[DDPDanmakuSettingMessage alloc] init];
            DDPCacheManager *cache = DDPCacheManager.shareCacheManager;
            UIFont *font = cache.danmakuFont;
            aMessage.fontName = font.fontName;
            aMessage.fontSize = font.pointSize;
            aMessage.effectStyle = cache.danmakuEffectStyle;
            aMessage.filters = cache.danmakuFilters;
            aMessage.danmakuOpacity = cache.danmakuOpacity;
            aMessage.danmakuSpeed = cache.danmakuSpeed;
            aMessage.danmakuLimitCount = cache.danmakuLimitCount;
            aMessage.danmakuShieldType = cache.danmakuShieldType;
            
            [[DDPMessageManager sharedManager] sendMessage:aMessage];
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
    let dropInteraction = [[UIDropInteraction alloc] initWithDelegate:self];
    [self.view addInteraction:dropInteraction];
}

- (void)parseWithURL:(NSURL *)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        DDPFile *file = [[DDPFile alloc] initWithFileURL:url type:DDPFileTypeDocument];
        [DDPMethod matchFile:file completion:nil];      
    });
}

@end
