//
//  PickerFileViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "PickerFileViewController.h"

#import "FileManagerPickFileView.h"

@interface PickerFileViewController ()<FileManagerViewDelegate>
@property (strong, nonatomic) FileManagerPickFileView *fileManagerView;
@end

@implementation PickerFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == PickerFileTypeDanmaku) {
        self.title = @"选择弹幕";
    }
    else {
        self.title = @"选择字幕";
    }
    
    [self.fileManagerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.fileManagerView refreshingWithAnimate:NO];
}

#pragma mark - FileManagerViewDelegate
- (void)managerView:(FileManagerView *)managerView didselectedModel:(JHSMBFile *)file {
    if (self.selectedFileCallBack) {
        self.selectedFileCallBack(file);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 懒加载
- (FileManagerPickFileView *)fileManagerView {
    if (_fileManagerView == nil) {
        _fileManagerView = [[FileManagerPickFileView alloc] init];
        _fileManagerView.delegate = self;
        _fileManagerView.currentFile = _file;
        _fileManagerView.fileType = _type;
        [self.view addSubview:_fileManagerView];
    }
    return _fileManagerView;
}

@end
