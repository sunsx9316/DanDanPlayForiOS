//
//  AboutUsViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/4/26.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "AboutUsViewController.h"

#import "UIApplication+Tools.h"

@interface AboutUsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *officialWebsiteButton;
@property (weak, nonatomic) IBOutlet UIButton *openSourceButton;
@property (weak, nonatomic) IBOutlet UILabel *copyrightLabel;
@property (weak, nonatomic) IBOutlet UIView *insertView;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.officialWebsiteButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [self.openSourceButton setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    self.insertView.backgroundColor = MAIN_COLOR;
    self.titleLabel.text = [UIApplication sharedApplication].appDisplayName;
    self.versionLabel.text = [NSString stringWithFormat:@"v%@", [UIApplication sharedApplication].appVersion];
    NSLog(@"%@", [NSBundle mainBundle].infoDictionary);
    
    NSDate *date = [NSDate date];
    NSString *year = nil;
    if (date.year == 2017) {
        year = @"2017";
    }
    else {
        year = [NSString stringWithFormat:@"2017-%ld", date.year];
    }
    self.copyrightLabel.text = [NSString stringWithFormat:@"Copyright © %@年 JimHuang. All rights reserved.", year];
}

- (IBAction)touchOfficialWebsiteButton:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.dandanplay.com"]];
}

- (IBAction)touchOpenSourceButton:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/sunsx9316/DanDanPlayForiOS"]];
}

@end
