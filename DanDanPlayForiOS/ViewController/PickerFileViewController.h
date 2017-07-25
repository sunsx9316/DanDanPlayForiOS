//
//  PickerFileViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/5/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//  选择字幕

#import "BaseViewController.h"

@interface PickerFileViewController : BaseViewController
@property (assign, nonatomic) PickerFileType type;
@property (strong, nonatomic) JHSMBFile *file;
@property (copy, nonatomic) void(^selectedFileCallBack)(JHSMBFile *);
@end