//
//  DDPBaseWebViewController.m
//  BiliBili
//
//  Created by apple-jd44 on 15/10/28.
//  Copyright © 2015年 JimHuang. All rights reserved.
//

#import "DDPBaseWebViewController.h"

@interface DDPBaseWebViewController ()
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) CALayer *progressLayer;
@property (strong, nonatomic) NSURLRequest *request;
@end

@implementation DDPBaseWebViewController

- (instancetype)initWithURL:(NSURL *)URL {
    return [self initWithRequest:[NSURLRequest requestWithURL:URL]];
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
    if (self = [self init]) {
        _request = request;
    }
    return self;
}

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
    [self configRightItem];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    [self.webView loadRequest:self.request];
    
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (_showProgressView) {
            float progress = [change[NSKeyValueChangeNewKey] floatValue];
            self.progressLayer.frame = CGRectMake(0, 0, self.view.width * progress, 3);
            LOG_DEBUG(DDPLogModuleOther, @"网页加载百分比 %f", progress);
        }
    }
    else if ([keyPath isEqualToString:@"title"]) {
        self.navigationItem.title = change[NSKeyValueChangeNewKey];
    }
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

#pragma mark - WKNavigationDelegate

// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressLayer.hidden = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: YES];
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    self.progressLayer.hidden = YES;
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: NO];
    self.progressLayer.hidden = YES;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    //如果是跳转一个新页面
    
    NSString *scheme = navigationAction.request.URL.scheme;
    if ([scheme isEqualToString:@"magnet"] || [scheme isEqualToString:@"ddplay"]) {
        if (self.clickMagnetCallBack) {
            self.clickMagnetCallBack(navigationAction.request.URL.absoluteString);
        }
    }
    else {
        if (navigationAction.targetFrame == nil) {
            DDPBaseWebViewController *vc = [[DDPBaseWebViewController alloc] initWithRequest:navigationAction.request];
            vc.clickMagnetCallBack = self.clickMagnetCallBack;
            vc.showProgressView = self.showProgressView;
            [self.navigationController pushViewController:vc animated:YES];
        }        
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - 私有方法
- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_browser"] configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)sender {
    if (self.request.URL) {
        [[UIApplication sharedApplication] openURL:self.request.URL];
    }
}

#pragma mark - 懒加载
- (WKWebView *)webView {
	if(_webView == nil) {
		_webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self.view addSubview:_webView];
	}
	return _webView;
}

- (CALayer *)progressLayer {
    if (_progressLayer == nil) {
        _progressLayer = [CALayer layer];
        _progressLayer.backgroundColor = DDPRGBColor(49, 169, 226).CGColor;
        [self.view.layer insertSublayer:_progressLayer above:self.webView.layer];
    }
    return _progressLayer;
}

@end
