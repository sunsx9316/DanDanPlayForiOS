//
//  WebViewController.m
//  BiliBili
//
//  Created by apple-jd44 on 15/10/28.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) CALayer *progressLayer;
@end

@implementation WebViewController

- (instancetype)init {
    if (self = [super init]) {
        _showProgressView = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (_showProgressView) {
            float progress = [change[NSKeyValueChangeNewKey] floatValue];
            self.progressLayer.frame = CGRectMake(0, 0, self.view.width * progress, 3);
            NSLog(@"%f", progress);
            if (progress == 1) {
                self.progressLayer.hidden = YES;
            }
        }
    }
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

//- (void)touchLeftItem:(UIButton *)button {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - WKNavigationDelegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

#pragma mark - 懒加载
- (WKWebView *)webView {
	if(_webView == nil) {
		_webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [self.view addSubview:_webView];
	}
	return _webView;
}

- (CALayer *)progressLayer {
    if (_progressLayer == nil) {
        _progressLayer = [CALayer layer];
        _progressLayer.backgroundColor = RGBCOLOR(49, 169, 226).CGColor;
        [self.view.layer insertSublayer:_progressLayer above:self.webView.layer];
    }
    return _progressLayer;
}

@end
