//
//  DDPAboutUsViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPAboutUsViewController.h"
#import "UIApplication+Tools.h"
#import "DDPEdgeButton.h"

@interface DDPAboutUsViewController ()
@property (strong, nonatomic) UIImageView *iconImgView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *versionLabel;
@property (strong, nonatomic) UIView *holdView;
@property (strong, nonatomic) DDPEdgeButton *officialButton;
@property (strong, nonatomic) DDPEdgeButton *openSourceButton;
@property (strong, nonatomic) DDPEdgeButton *weiboButton;
@property (strong, nonatomic) UILabel *copyrightLabel;

@end

@implementation DDPAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"关于%@", [UIApplication sharedApplication].appDisplayName];
    
    [self configRightItem];
    
    [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.mas_offset(30);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.iconImgView.mas_bottom).mas_offset(5);
    }];
    
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(5);
    }];
    
    [self.holdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.bottom.equalTo(self.copyrightLabel.mas_top).mas_offset(-10);
    }];

    [self.copyrightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(10);
        make.right.mas_offset(-10);
        make.bottom.mas_offset(-20);
    }];
}

- (void)touchOfficialWebsiteButton:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.dandanplay.com"]];
}

- (void)touchOpenSourceButton:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/sunsx9316/DanDanPlayForiOS"]];
}

- (void)touchWeiboButton:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://weibo.com/u/2996607392"]];
}

#pragma mark - 私有方法
- (void)configRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"评价一发" configAction:^(UIButton *aButton) {
        [aButton addTarget:self action:@selector(touchRightItem:) forControlEvents:UIControlEventTouchUpInside];
        [aButton setTitle:@"评价一发" forState:UIControlStateNormal];
    }];
    
    [self.navigationItem addRightItemFixedSpace:item];
}

- (void)touchRightItem:(UIButton *)button {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_LINK]];
}

#pragma mark - 懒加载
- (UIImageView *)iconImgView {
    if (_iconImgView == nil) {
        _iconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_icon"]];
        [self.view addSubview:_iconImgView];
    }
    return _iconImgView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.text = [UIApplication sharedApplication].appDisplayName;
        _titleLabel.font = [UIFont ddp_veryBigSizeFont];
        [self.view addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)versionLabel {
    if (_versionLabel == nil) {
        _versionLabel = [[UILabel alloc] init];
        _versionLabel.text = [NSString stringWithFormat:@"v%@", [UIApplication sharedApplication].appVersion];
        _versionLabel.font = [UIFont ddp_smallSizeFont];
        _versionLabel.textColor = [UIColor lightGrayColor];
        [self.view addSubview:_versionLabel];
    }
    return _versionLabel;
}

- (DDPEdgeButton *)officialButton {
    if (_officialButton == nil) {
        _officialButton = [[DDPEdgeButton alloc] init];
        _officialButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        _officialButton.inset = CGSizeMake(10, 10);
        [_officialButton setTitle:@"官网" forState:UIControlStateNormal];
        [_officialButton addTarget:self action:@selector(touchOfficialWebsiteButton:) forControlEvents:UIControlEventTouchUpInside];
        [_officialButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
    }
    return _officialButton;
}

- (DDPEdgeButton *)openSourceButton {
    if (_openSourceButton == nil) {
        _openSourceButton = [[DDPEdgeButton alloc] init];
        _openSourceButton.inset = CGSizeMake(10, 10);
        _openSourceButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        [_openSourceButton setTitle:@"开源地址" forState:UIControlStateNormal];
        [_openSourceButton addTarget:self action:@selector(touchOpenSourceButton:) forControlEvents:UIControlEventTouchUpInside];
        [_openSourceButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
    }
    return _openSourceButton;
}

- (DDPEdgeButton *)weiboButton {
    if (_weiboButton == nil) {
        _weiboButton = [[DDPEdgeButton alloc] init];
        _weiboButton.inset = CGSizeMake(10, 10);
        _weiboButton.titleLabel.font = [UIFont ddp_smallSizeFont];
        [_weiboButton setTitle:@"@我" forState:UIControlStateNormal];
        [_weiboButton setTitleColor:[UIColor ddp_mainColor] forState:UIControlStateNormal];
        [_weiboButton addTarget:self action:@selector(touchWeiboButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _weiboButton;
}

- (UIView *)holdView {
    if (_holdView == nil) {
        _holdView = [[UIView alloc] init];
        
        [_holdView addSubview:self.officialButton];
        [_holdView addSubview:self.openSourceButton];
        [_holdView addSubview:self.weiboButton];
        
        UIView *insertView1 = [[UIView alloc] init];
        insertView1.backgroundColor = [UIColor ddp_mainColor];
        
        UIView *insertView2 = [[UIView alloc] init];
        insertView2.backgroundColor = [UIColor ddp_mainColor];
        [_holdView addSubview:insertView1];
        [_holdView addSubview:insertView2];
        
        [self.officialButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.mas_equalTo(0);
        }];
        
        [insertView1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.officialButton.mas_right);
            make.size.mas_equalTo(CGSizeMake(1, 15));
        }];
        
        [self.openSourceButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(insertView1.mas_right);
        }];
        
        [insertView2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.left.equalTo(self.openSourceButton.mas_right);
            make.size.mas_equalTo(insertView1);
        }];
        
        [self.weiboButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(0);
            make.left.equalTo(insertView2.mas_right);
        }];
        
        [self.view addSubview:_holdView];
    }
    return _holdView;
}

- (UILabel *)copyrightLabel {
    if (_copyrightLabel == nil) {
        _copyrightLabel = [[UILabel alloc] init];
        _copyrightLabel.font = [UIFont ddp_verySmallSizeFont];
        _copyrightLabel.textColor = [UIColor lightGrayColor];
        _copyrightLabel.numberOfLines = 0;
        _copyrightLabel.textAlignment = NSTextAlignmentCenter;
    
        NSDate *date = [NSDate date];
        NSString *year = nil;

        if (date.year > 2017) {
            year = [NSString stringWithFormat:@"2017-%ld", (long)date.year];
        }
        else {
            year = @"2017";
        }
    
        _copyrightLabel.text = [NSString stringWithFormat:@"Copyright © %@年 JimHuang. All rights reserved.", year];
        
        [self.view addSubview:_copyrightLabel];
    }
    return _copyrightLabel;
}

@end
