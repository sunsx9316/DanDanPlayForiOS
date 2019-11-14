//
//  DDPHTTPServerViewController.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 17/3/5.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHTTPServerViewController.h"
#import <HTTPServer.h>
#import "DDPEdgeButton.h"
#import "DDPActivityEdgeLabel.h"
#import "DDPHttpReceiveTableViewCell.h"
#import <UITableView+FDTemplateLayoutCell.h>
#import "DDPHttpReceive.h"
#import "DDPTransparentNavigationBar.h"
#import "DDPSharedNetManager.h"

@interface DDPHTTPServerViewController ()<UITableViewDelegate, UITableViewDataSource, DDPBaseNetManagerObserver>
@property (strong, nonatomic) UIImageView *wifiImgView;
@property (strong, nonatomic) UIView *bgView;
@property (strong, nonatomic) DDPActivityEdgeLabel *ipLabel;
@property (strong, nonatomic) UILabel *topNoticeLabel;
@property (strong, nonatomic) UILabel *wifiNoticeLabel;
@property (strong, nonatomic) UIView *holdView;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray <DDPHttpReceive *>*receiveFiles;
@end

@implementation DDPHTTPServerViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //屏幕常亮
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"WiFi传视频";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startReceiveFile:) name:START_RECEIVE_FILE_NOTICE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeFileSuccess:) name:WRITE_FILE_SUCCESS_NOTICE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFileProgress:) name:RECEIVE_FILE_PROGRESS_NOTICE object:nil];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(self.view).multipliedBy(0.4);
    }];
    
    
    [self.holdView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_bottom);
        make.left.right.mas_equalTo(0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.top.equalTo(self.holdView.mas_bottom);
        make.height.mas_equalTo(0);
    }];
    
    [self startHTTPServer];
    
    [[DDPSharedNetManager sharedNetManager] addObserver:self];

}

- (void)dealloc {
    [[DDPSharedNetManager sharedNetManager] removeObserver:self];
    [[DDPToolsManager shareHTTPServer] stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (Class)ddp_navigationBarClass {
    return [DDPTransparentNavigationBar class];
}

#pragma mark - DDPBaseNetManagerObserver
- (void)netStatusChange:(YYReachability *)reachability {
    if (reachability.status == YYReachabilityStatusWiFi) {
        HTTPServer *httpServer = [DDPToolsManager shareHTTPServer];
        if (httpServer.isRunning == NO) {
            [DDPToolsManager resetHTTPServer];
            [self startHTTPServer];
        }
        else {
            [self showSuccessUI];
        }
    }
    else {
        [self showErrorUI];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.receiveFiles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DDPHttpReceiveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DDPHttpReceiveTableViewCell" forIndexPath:indexPath];
    DDPHttpReceive *receive = self.receiveFiles[indexPath.row];
    [self updateModel:receive cell:cell];
    return cell;
}

#pragma mark - 私有方法
- (void)touchLeftItem:(UIButton *)button {
    [super touchLeftItem:button];
    if (self.receiveFiles.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:COPY_FILE_AT_OTHER_APP_SUCCESS_NOTICE object:nil];
    }
}

- (void)showSuccessUI {
    HTTPServer *httpServer = [DDPToolsManager shareHTTPServer];
    self.bgView.backgroundColor = [UIColor ddp_mainColor];
    self.ipLabel.backgroundColor = [UIColor ddp_mainColor];
    self.ipLabel.text = [NSString stringWithFormat:@"http://%@:%hu", [httpServer interface], [httpServer listeningPort]];
    self.wifiNoticeLabel.text = @"在电脑浏览器输入这个地址有惊喜(￣∇￣)";
}

- (void)showErrorUI {
    self.bgView.backgroundColor = DDPRGBColor(227, 23, 13);
    self.ipLabel.backgroundColor = self.bgView.backgroundColor;
    self.ipLabel.text = @"没有连上Wifi";
    self.wifiNoticeLabel.text = nil;
}

- (BOOL)startHTTPServer {
    NSError *error = nil;
    BOOL success = [[DDPToolsManager shareHTTPServer] start:&error];
    if(success == NO) {
        LOG_ERROR(DDPLogModuleFile, @"Error starting HTTP Server: %@", error);
        [self showErrorUI];
    }
    else {
        [self showSuccessUI];
    }
    
    return success;
}

- (void)longPressWifiNoticeLabel:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.ipLabel becomeFirstResponder];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        CGRect rect = CGRectZero;
        rect.origin = CGPointMake([gesture locationInView:self.ipLabel].x, 0);
        
        [menuController setTargetRect:rect inView:self.ipLabel];
        [menuController setMenuVisible:YES animated:YES];
    }
}

- (void)updateModel:(DDPHttpReceive *)model cell:(DDPHttpReceiveTableViewCell *)cell {
    cell.iconImgView.hidden = model.progress < 1;
    cell.progressView.progress = model.progress;
    cell.titleLabel.text = model.filePath.lastPathComponent;
}

#pragma mark 通知
- (void)startReceiveFile:(NSNotification *)aNotification {
    DDPHttpReceive *receive = aNotification.object;
    
    if (self.receiveFiles.count == 0) {
        [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(0);
            make.top.equalTo(self.holdView.mas_bottom);
            make.height.mas_equalTo(self.view).multipliedBy(0.35);
        }];
        
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:1 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }
    
    [self.receiveFiles addObject:receive];
    [self.tableView insertRow:self.receiveFiles.count - 1 inSection:0 withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)writeFileSuccess:(NSNotification *)notice {
    DDPHttpReceive *receive = notice.object;
    
    [self.receiveFiles enumerateObjectsUsingBlock:^(DDPHttpReceive * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.filePath isEqualToString:receive.filePath]) {
            DDPHttpReceiveTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            obj.progress = 1;
            [self updateModel:obj cell:cell];
            *stop = YES;
        }
    }];
}

- (void)receiveFileProgress:(NSNotification *)aNotification {
    DDPHttpReceive *receive = aNotification.object;
    [self.receiveFiles enumerateObjectsUsingBlock:^(DDPHttpReceive * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.filePath isEqualToString:receive.filePath]) {
            DDPHttpReceiveTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
            obj.progress = receive.progress;
            [self updateModel:obj cell:cell];
            *stop = YES;
        }
    }];
}

#pragma mark - 懒加载

- (UIView *)bgView {
    if (_bgView == nil) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor ddp_mainColor];
        
        [_bgView addSubview:self.wifiImgView];
        [_bgView addSubview:self.topNoticeLabel];
        
        [self.wifiImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
        }];
        
        [self.topNoticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.wifiImgView.mas_bottom).mas_offset(20);
            make.left.mas_offset(20);
            make.right.mas_offset(-20);
        }];
        
        [self.view addSubview:_bgView];
    }
    return _bgView;
}

- (UIView *)holdView {
    if (_holdView == nil) {
        _holdView = [[UIView alloc] init];
        [_holdView addSubview:self.ipLabel];
        [_holdView addSubview:self.wifiNoticeLabel];
        
        [self.ipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(0);
            make.height.mas_equalTo(self.ipLabel.font.lineHeight + 10);
        }];
        
        [self.wifiNoticeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.bottom.equalTo(self.ipLabel.mas_top).mas_offset(-10);
        }];
        
        [self.view addSubview:_holdView];
    }
    return _holdView;
}

- (DDPActivityEdgeLabel *)ipLabel {
    if (_ipLabel == nil) {
        _ipLabel = [[DDPActivityEdgeLabel alloc] init];
        _ipLabel.inset = CGSizeMake(30, 0);
        _ipLabel.textAlignment = NSTextAlignmentCenter;
        _ipLabel.textColor = [UIColor whiteColor];
        _ipLabel.backgroundColor = [UIColor ddp_mainColor];
        _ipLabel.text = @"开启服务中...";
        _ipLabel.layer.masksToBounds = YES;
        _ipLabel.font = [UIFont ddp_bigSizeFont];
        _ipLabel.layer.cornerRadius = (_ipLabel.font.lineHeight + 10) / 2;
        _ipLabel.userInteractionEnabled = YES;
        [_ipLabel addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressWifiNoticeLabel:)]];
    }
    return _ipLabel;
}

- (UILabel *)wifiNoticeLabel {
    if (_wifiNoticeLabel == nil) {
        _wifiNoticeLabel = [[UILabel alloc] init];
        _wifiNoticeLabel.font = [UIFont ddp_normalSizeFont];
    }
    return _wifiNoticeLabel;
}

- (UILabel *)topNoticeLabel {
    if (_topNoticeLabel == nil) {
        _topNoticeLabel = [[UILabel alloc] init];
        _topNoticeLabel.numberOfLines = 0;
        _topNoticeLabel.textColor = [UIColor whiteColor];
        _topNoticeLabel.textAlignment = NSTextAlignmentCenter;
        _topNoticeLabel.text = @"果机需要和电脑在同一个局域网内，上传过程中，不要关闭这个页面(｀･ω･)";
        _topNoticeLabel.font = [UIFont ddp_normalSizeFont];
    }
    return _topNoticeLabel;
}

- (UIImageView *)wifiImgView {
    if (_wifiImgView == nil) {
        _wifiImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"file_wifi"]];
    }
    return _wifiImgView;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[DDPHttpReceiveTableViewCell class] forCellReuseIdentifier:@"DDPHttpReceiveTableViewCell"];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 44;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (NSMutableArray<DDPHttpReceive *> *)receiveFiles {
    if (_receiveFiles == nil) {
        _receiveFiles = [NSMutableArray array];
    }
    return _receiveFiles;
}

@end

