//
//  JHQRHelpViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/11/12.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHQRHelpViewController.h"
#import "JHBaseScrollView.h"
#import "JHFileTreeNode.h"
#import "JHEdgeButton.h"

@interface JHQRHelpViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) JHBaseScrollView *scrollView;

@property (strong, nonatomic) NSArray <JHFileTreeNode *>*dataSource;
@property (strong, nonatomic) JHEdgeButton *scannerButton;
@end

@implementation JHQRHelpViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setNavigationBarWithColor:[UIColor clearColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"二维码在哪?";
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.scrollView.mas_top).mas_offset(-15);
        make.left.mas_offset(15);
        make.right.mas_offset(-15);
    }];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_offset(15);
//        make.right.mas_offset(-15);
        make.center.mas_equalTo(0);
        make.width.mas_equalTo(self.view).mas_offset(-30);
        make.height.mas_equalTo(self.view).multipliedBy(0.4);
    }];
    
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.scrollView.mas_bottom).mas_offset(10);
    }];
    
    [self.scannerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.mas_offset(-20);
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSUInteger page = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage = page;
    self.titleLabel.text = self.dataSource[page].name;
}

#pragma mark - 私有方法
- (void)touchScannerButton:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 懒加载
- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = NORMAL_SIZE_FONT;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = self.dataSource.firstObject.name;
        _titleLabel.numberOfLines = 0;
        [self.view addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (JHBaseScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[JHBaseScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.bounces = NO;

        __block UIImageView *preImgView = nil;
        [self.dataSource enumerateObjectsUsingBlock:^(JHFileTreeNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImageView *imgView = [[UIImageView alloc] initWithImage:obj.img];
            imgView.contentMode = UIViewContentModeScaleAspectFit;
            imgView.clipsToBounds = YES;
            [_scrollView addSubview:imgView];
            
            if (preImgView == nil) {
                [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.left.bottom.mas_equalTo(0);
                    make.size.mas_equalTo(self.scrollView);
                }];
            }
            else {
                [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.centerY.mas_equalTo(preImgView);
                    make.left.mas_equalTo(preImgView.mas_right);
                }];
            }
            
            preImgView = imgView;
        }];
        
        [preImgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
        }];
        
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.numberOfPages = self.dataSource.count;
        _pageControl.userInteractionEnabled = NO;
        [self.view addSubview:_pageControl];
    }
    return _pageControl;
}

- (NSArray<JHFileTreeNode *> *)dataSource {
    if (_dataSource == nil) {
        NSMutableArray <JHFileTreeNode *>*arr = [NSMutableArray array];
        NSArray <UIImage *>*imgs = [UIImage animatedImageNamed:@"qr_help" duration:0].images;
        
        [arr addObject:({
            JHFileTreeNode *node = [[JHFileTreeNode alloc] init];
            node.img = imgs.firstObject;
            node.name = @"点击电脑版顶部的“远程访问”\n弹出二维码";
            node;
        })];
        
        [arr addObject:({
            JHFileTreeNode *node = [[JHFileTreeNode alloc] init];
            node.img = imgs[1];
            node.name = @"点击“开启远程访问”\n使用APP扫描二维码连接电脑";
            node;
        })];
        
        _dataSource = arr;
    }
    return _dataSource;
}

- (JHEdgeButton *)scannerButton {
    if (_scannerButton == nil) {
        _scannerButton = [[JHEdgeButton alloc] init];
        _scannerButton.inset = CGSizeMake(40, 6);
        [_scannerButton setTitle:@"去扫码" forState:UIControlStateNormal];
        _scannerButton.titleLabel.font = BIG_SIZE_FONT;
        [_scannerButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
        _scannerButton.layer.borderWidth = 2;
        _scannerButton.layer.borderColor = MAIN_COLOR.CGColor;
        _scannerButton.layer.cornerRadius = 10;
        _scannerButton.layer.masksToBounds = YES;
        [_scannerButton addTarget:self action:@selector(touchScannerButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_scannerButton];
    }
    return _scannerButton;
}

@end
