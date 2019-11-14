//
//  DDPQRScannerViewController.m
//  TJSecurity
//
//  Created by JimHuang on 2017/7/14.
//  Copyright © 2017年 convoy. All rights reserved.
//

#import "DDPQRScannerViewController.h"
#import "JHQRCodeReader.h"
#import "DDPEdgeButton.h"
#import "DDPQRHelpViewController.h"
#import "DDPCacheManager+multiply.h"
#import "DDPQRScannerHistoryView.h"
#import "DDPTransparentNavigationBar.h"
#import "CALayer+Animation.h"

#define SCANNER_SIZE (MIN([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width) * 0.7)

@interface DDPQRScannerViewController ()
@property (strong, nonatomic) JHQRCodeReader *QRCodeReader;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) DDPEdgeButton *historyButton;
@property (strong, nonatomic) DDPEdgeButton *button;
@property (strong, nonatomic) DDPEdgeButton *noticeButton;
@end

@implementation DDPQRScannerViewController

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.QRCodeReader stopScanning];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.QRCodeReader startScanning];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"扫码连接电脑版";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view.layer addSublayer:self.QRCodeReader.previewLayer];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.historyButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_offset(20 + CGRectGetHeight(self.navigationController.navigationBar.frame));
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-15);
        make.centerX.mas_equalTo(0);
    }];
    
    [self.noticeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_offset(SCANNER_SIZE / 2 + 30);
        make.centerX.mas_equalTo(0);
    }];
    
    if ([JHQRCodeReader isAuthorization] == NO) {
        NSString *appName = [UIApplication sharedApplication].appDisplayName;
        UIAlertController *vc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"请在设置-%@中允许%@访问您的相机~", appName, appName] message:nil preferredStyle:UIAlertControllerStyleAlert];
        [vc addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }]];
        
        [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [self presentViewController:vc animated:YES completion:nil];
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.QRCodeReader startScanning];
        });
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.QRCodeReader.previewLayer.frame = self.view.bounds;
    [self addQRLayer];
}

- (Class)ddp_navigationBarClass {
    return [DDPTransparentNavigationBar class];
}

- (void)dealloc {
    [self.QRCodeReader stopScanning];
}

#pragma mark - 私有方法
- (void)scanResultWithText:(NSString *)text {
    LOG_INFO(DDPLogModuleFile, @"搜索 %@", text);
    
    NSDictionary *dic = [text jsonValueDecoded];
    if (dic) {
        [self.QRCodeReader stopScanning];
        
        DDPLinkInfo *info = [DDPLinkInfo yy_modelWithJSON:dic];

        if (info.ipAdress.count) {
            UIAlertController *vc = nil;
            
            if (info.ipAdress.count == 1) {
                NSString *ip = [NSString stringWithFormat:@"http://%@:%lu", info.ipAdress.firstObject, (unsigned long)info.port];

                vc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"是否连接到%@", info.name] message:ip preferredStyle:UIAlertControllerStyleAlert];
                [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self selectedIp:ip info:info];
                }]];
            }
            //多网卡情况
            else {
                vc = [UIAlertController alertControllerWithTitle:@"提示" message:@"选择一个ip或域名进行连接~" preferredStyle:UIAlertControllerStyleAlert];

                [info.ipAdress enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                    NSString *aIp = [NSString stringWithFormat:@"http://%@:%lu", obj, (unsigned long)info.port];
                    [vc addAction:[UIAlertAction actionWithTitle:aIp style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [self selectedIp:aIp info:info];
                    }]];
                }];
            }

            [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                [self.QRCodeReader startScanning];
            }]];
            
            [self presentViewController:vc animated:YES completion:nil];
        }
    }
}

- (void)touchButton:(UIButton *)button {
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"手动输入ip或域名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    @weakify(vc)
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = [UIFont ddp_normalSizeFont];
        textField.placeholder = @"如: 192.168.1.1:80";
    }];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = weak_vc.textFields.firstObject.text;
        
        if (text.length == 0) {
            [self.view showWithText:@"请输入ip!"];
            return;
        }
        
        if ([text hasPrefix:@"http://"] == NO && [text hasPrefix:@"https://"] == NO) {
            text = [NSString stringWithFormat:@"http://%@", text];
        }
        
        [self selectedIp:text info:[[DDPLinkInfo alloc] init]];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:^{
        [weak_vc.textFields.firstObject becomeFirstResponder];
    }];
}

- (void)selectedIp:(NSString *)ipAddress info:(DDPLinkInfo *)info {
    [self.view showLoading];
    
    [DDPLinkNetManagerOperation linkWithIpAdress:ipAddress completionHandler:^(DDPLinkWelcome *responseObject, NSError *error) {
        [self.view hideLoading];
        
        if (error) {
            [self.view showWithText:@"连接失败！请尝试重新开启远程访问" hideAfterDelay:2];
            [self.QRCodeReader startScanning];
        }
        else {
            //PC端版本满足
            
            if ([responseObject.version compare:WIN_MINI_LINK_VERSION options:NSNumericSearch] == NSOrderedAscending) {
                UIAlertController *warningVC = [UIAlertController alertControllerWithTitle:@"当前电脑版版本过旧，请更新到最新版后使用" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [warningVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.QRCodeReader startScanning];
                }]];
                [self presentViewController:warningVC animated:YES completion:nil];
            }
            else {
                @weakify(self)
                //先尝试请求 如果返回401 则要求输入密码
                [DDPLinkNetManagerOperation linkGetVideoInfoWithIpAdress:ipAddress completionHandler:^(DDPLibrary *model, NSError *error) {
                    @strongify(self)
                    if (!self) {
                        return;
                    }
                    
                    if ([error.localizedDescription containsString:@"401"]) {
                        
                        [self showInputAPIAlertVCWithInfo:info ip:ipAddress inputNoCorrect:false completion:^{
                            if (self.linkSuccessCallBack) {
                                self.linkSuccessCallBack(info);
                            }
                        }];
                        
                    }
                    else {
                        info.selectedIpAdress = ipAddress;
                        [DDPCacheManager shareCacheManager].linkInfo = info;
    
                        [[DDPCacheManager shareCacheManager] addLinkInfo:info];
    
                        if (self.linkSuccessCallBack) {
                            self.linkSuccessCallBack(info);
                        }
                    }
                }];
            }
        }
    }];
}

//显示输入秘钥弹窗
- (void)showInputAPIAlertVCWithInfo:(DDPLinkInfo *)info
                                 ip:(NSString *)ipAddress
                     inputNoCorrect:(BOOL)inputNoCorrect
                         completion:(void(^)(void))completion {
    
    let title = inputNoCorrect ? @"密码错误! 请重新输入" : @"请输入API秘钥";
    
    @weakify(self)
    UIAlertController *warningVC = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    [warningVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        [textField.layer shake];
    }];
    __weak UITextField *weakTextField = warningVC.textFields.firstObject;
    [warningVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        if (!self) {
            return;
        }
        
        info.apiToken = weakTextField.text;
        info.selectedIpAdress = ipAddress;
        [DDPCacheManager shareCacheManager].linkInfo = info;
        
        [DDPLinkNetManagerOperation linkGetVideoInfoWithIpAdress:ipAddress completionHandler:^(DDPLibrary *model, NSError *error) {
            if ([error.localizedDescription containsString:@"401"]) {
                
                [self showInputAPIAlertVCWithInfo:info ip:ipAddress inputNoCorrect:true completion:completion];
                
            }
            else {
                [[DDPCacheManager shareCacheManager] addLinkInfo:info];
                
                if (completion) {
                    completion();
                }
            }
        }];
        
    }]];
    
    [warningVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.QRCodeReader startScanning];
    }]];
    
    [self presentViewController:warningVC animated:YES completion:nil];
}

- (void)touchHelpButton:(UIButton *)sender {
    DDPQRHelpViewController *vc = [[DDPQRHelpViewController alloc] init];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)touchHistoryButton:(UIButton *)sender {
    DDPQRScannerHistoryView *view = [[DDPQRScannerHistoryView loadNib] instantiateWithOwner:nil options:nil].firstObject;
    @weakify(self)
    view.selectedInfoCallBack = ^(DDPLinkInfo *info) {
        @strongify(self)
        if (!self) return;
        
        [self selectedIp:info.selectedIpAdress info:info];
    };
    [view show];
}

- (void)addQRLayer {
    [self.maskView.layer removeAllSublayers];
    
    CAShapeLayer* cropLayer = [[CAShapeLayer alloc] init];
    [self.maskView.layer addSublayer:cropLayer];
    
    // 创建一个绘制路径
    CGMutablePathRef path = CGPathCreateMutable();
    // 空心矩形的rect
    float width = SCANNER_SIZE;
    CGRect cropRect = CGRectMake((self.view.width - width) / 2, (self.view.height - width) / 2, width, width);
    CGPathAddRect(path, nil, self.view.bounds);
    CGPathAddRect(path, nil, cropRect);
    cropLayer.fillRule = kCAFillRuleEvenOdd;
    cropLayer.path = path;
    cropLayer.fillColor = DDPRGBAColor(0, 0, 0, 0.6).CGColor;
    CGPathRelease(path);
    
    
    //绘制虚线
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.frame = cropRect;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.lineWidth = 2;
    shapeLayer.lineJoin = kCALineJoinRound;
    //设置线宽，线间距
    [shapeLayer setLineDashPattern:@[@14, @7]];
    
    UIBezierPath *linkPath = [UIBezierPath bezierPathWithRoundedRect:(CGRect){-1, -1, CGSizeMake(cropRect.size.width + 2, cropRect.size.height + 2)} cornerRadius:6];
    [shapeLayer setPath:linkPath.CGPath];
    
    [self.maskView.layer addSublayer:shapeLayer];
}

#pragma mark - 懒加载

- (JHQRCodeReader *)QRCodeReader {
    if (_QRCodeReader == nil) {
        _QRCodeReader = [[JHQRCodeReader alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
        float size = SCANNER_SIZE;
        _QRCodeReader.metadataOutput.rectOfInterest = CGRectMake((self.view.height - size) / 2 / self.view.height, (self.view.width - size) / 2 / self.view.width, size / self.view.height, size / self.view.width);
        @weakify(self)
        [_QRCodeReader setCompletionWithBlock:^(NSString * _Nullable resultAsString) {
            @strongify(self)
            if (!self) return;
            
            [self scanResultWithText:resultAsString];
        }];
    }
    return _QRCodeReader;
}

- (UIView *)maskView {
    if (_maskView == nil) {
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_maskView];
    }
    return _maskView;
}

- (DDPEdgeButton *)historyButton {
    if (_historyButton == nil) {
        _historyButton = [[DDPEdgeButton alloc] init];
        _historyButton.inset = CGSizeMake(20, 10);
        [_historyButton setImage:[[UIImage imageNamed:@"filter_arrow_down"] yy_imageByTintColor:[UIColor whiteColor]] forState:UIControlStateNormal];
//        _historyButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        _historyButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        [_historyButton setTitle:@"扫描历史" forState:UIControlStateNormal];
        _historyButton.backgroundColor = DDPRGBAColor(100, 100, 100, 0.7);
        _historyButton.layer.cornerRadius = 10;
        _historyButton.layer.masksToBounds = YES;
        _historyButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_historyButton addTarget:self action:@selector(touchHistoryButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_historyButton];
    }
    return _historyButton;
}

- (DDPEdgeButton *)button {
    if (_button == nil) {
        _button = [[DDPEdgeButton alloc] init];
        _button.titleLabel.font = [UIFont ddp_normalSizeFont];
        _button.inset = CGSizeMake(20, 20);
        [_button setTitle:@"点我手动输入地址~(￣▽￣)" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
        [_button setTitleColor:DDPRGBColor(180, 180, 180) forState:UIControlStateNormal];
        [self.view addSubview:_button];
    }
    return _button;
}

- (DDPEdgeButton *)noticeButton {
    if (_noticeButton == nil) {
        _noticeButton = [[DDPEdgeButton alloc] init];
        _noticeButton.inset = CGSizeMake(20, 0);
        _noticeButton.titleLabel.font = [UIFont ddp_normalSizeFont];
        [_noticeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_noticeButton setTitle:@"二维码在哪?" forState:UIControlStateNormal];
        _noticeButton.backgroundColor = DDPRGBAColor(100, 100, 100, 0.7);
        _noticeButton.layer.cornerRadius = 10;
        _noticeButton.layer.masksToBounds = YES;
        [_noticeButton addTarget:self action:@selector(touchHelpButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_noticeButton];
    }
    return _noticeButton;
}


@end
