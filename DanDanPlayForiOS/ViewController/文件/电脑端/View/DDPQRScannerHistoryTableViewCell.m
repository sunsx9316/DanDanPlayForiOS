//
//  DDPQRScannerHistoryTableViewCell.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/2/16.
//  Copyright © 2018年 JimHuang. All rights reserved.
//

#import "DDPQRScannerHistoryTableViewCell.h"

@interface DDPQRScannerHistoryTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation DDPQRScannerHistoryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.font = [UIFont ddp_normalSizeFont];
    self.detailLabel.font = [UIFont ddp_smallSizeFont];
    self.detailLabel.textColor = [UIColor lightGrayColor];
}

- (void)setModel:(DDPLinkInfo *)model {
    _model = model;
    
    self.titleLabel.text = _model.name;
    self.detailLabel.text = _model.selectedIpAdress;
}

@end
