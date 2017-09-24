//
//  QRScanerViewController.m
//  TJSecurity
//
//  Created by JimHuang on 2017/7/14.
//  Copyright © 2017年 convoy. All rights reserved.
//

#import "QRScanerViewController.h"
#import "JHQRCodeReader.h"
#import "JHEdgeButton.h"
#import "UIApplication+Tools.h"

#define SCANNER_SIZE (self.view.width * 0.7)

@interface QRScanerViewController ()
@property (strong, nonatomic) JHQRCodeReader *QRCodeReader;
@property (strong, nonatomic) UIView *maskView;
@property (strong, nonatomic) JHEdgeButton *button;
@end

@implementation QRScanerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarWithColor:[UIColor clearColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"扫码连接";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view.layer addSublayer:self.QRCodeReader.previewLayer];
    
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_offset(-20);
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.QRCodeReader startScanning];
            });
        });
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.QRCodeReader.previewLayer.frame = self.view.bounds;
}

- (void)dealloc {
    [self.QRCodeReader stopScanning];
}

#pragma mark - 私有方法
- (void)scanResultWithText:(NSString *)text {
    NSLog(@"%@", text);
    
    NSDictionary *dic = [text jsonValueDecoded];
    if (dic) {
        [self.QRCodeReader stopScanning];
        
        JHLinkInfo *info = [JHLinkInfo yy_modelWithJSON:dic];

        if (info.ipAdress.count) {
            UIAlertController *vc = nil;
            
            if (info.ipAdress.count == 1) {
                NSString *ip = [NSString stringWithFormat:@"http://%@:%ld", info.ipAdress.firstObject, info.port];

                vc = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"是否连接到%@", info.name] message:ip preferredStyle:UIAlertControllerStyleAlert];
                [vc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self selectedIp:ip info:info];
                }]];
            }
            //多网卡情况
            else {
                vc = [UIAlertController alertControllerWithTitle:@"选择一个ip进行连接~" message:nil preferredStyle:UIAlertControllerStyleAlert];

                [info.ipAdress enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {

                    NSString *aIp = [NSString stringWithFormat:@"http://%@:%ld", obj, info.port];
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
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"手动输入ip" message:nil preferredStyle:UIAlertControllerStyleAlert];
    @weakify(vc)
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.font = NORMAL_SIZE_FONT;
        textField.placeholder = @"如: 192.168.1.1:80";
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = weak_vc.textFields.firstObject.text;
        
        if (text.length == 0) {
            [MBProgressHUD showWithText:@"请输入ip！"];
            return;
        }
        
        [self selectedIp:[NSString stringWithFormat:@"http://%@", text] info:[[JHLinkInfo alloc] init]];
    }]];
    
    [vc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:vc animated:YES completion:^{
        [weak_vc.textFields.firstObject becomeFirstResponder];
    }];
}

- (void)selectedIp:(NSString *)ipAddress info:(JHLinkInfo *)info {
    [MBProgressHUD showLoadingInView:self.view text:nil];
    
    [LinkNetManager linkWithIpAdress:ipAddress completionHandler:^(JHLinkWelcome *responseObject, NSError *error) {
        
        [MBProgressHUD hideLoading];
        
        if (error) {
            [MBProgressHUD showWithText:@"连接失败！请尝试重新开启远程访问" atView:self.view hideAfterDelay:2];
            [self.QRCodeReader startScanning];
        }
        else {
            //PC端版本满足
            if ([responseObject.version compare:WIN_MINI_LINK_VERSION] == NSOrderedAscending) {
                UIAlertController *warningVC = [UIAlertController alertControllerWithTitle:@"当前电脑版版本过旧，请更新到最新版后使用" message:nil preferredStyle:UIAlertControllerStyleAlert];
                [warningVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [self.QRCodeReader startScanning];
                }]];
                [self presentViewController:warningVC animated:YES completion:nil];
            }
            else {
                info.selectedIpAdress = ipAddress;
                [CacheManager shareCacheManager].linkInfo = info;
                if (self.linkSuccessCallBack) {
                    self.linkSuccessCallBack(info);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
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
        
        CAShapeLayer* cropLayer = [[CAShapeLayer alloc] init];
        [_maskView.layer addSublayer:cropLayer];
        
        // 创建一个绘制路径
        CGMutablePathRef path = CGPathCreateMutable();
        // 空心矩形的rect
        float width = SCANNER_SIZE;
        CGRect cropRect = CGRectMake((self.view.width - width) / 2, (self.view.height - width) / 2, width, width);
        CGPathAddRect(path, nil, self.view.bounds);
        CGPathAddRect(path, nil, cropRect);
        cropLayer.fillRule = kCAFillRuleEvenOdd;
        cropLayer.path = path;
        cropLayer.fillColor = RGBACOLOR(0, 0, 0, 0.6).CGColor;
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
        
        [_maskView.layer addSublayer:shapeLayer];
        [self.view addSubview:_maskView];
    }
    return _maskView;
}

- (JHEdgeButton *)button {
    if (_button == nil) {
        _button = [[JHEdgeButton alloc] init];
        _button.titleLabel.font = NORMAL_SIZE_FONT;
        _button.inset = CGSizeMake(20, 20);
        [_button setTitle:@"点我手动输入ip~(￣▽￣)" forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(touchButton:) forControlEvents:UIControlEventTouchUpInside];
        [_button setTitleColor:RGBCOLOR(180, 180, 180) forState:UIControlStateNormal];
        [self.view addSubview:_button];
    }
    return _button;
}

@end
