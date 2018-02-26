//
//  DDPSMBFileManagerPickerViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"
#import "DDPLocalFileManagerPickerViewController.h"

@interface DDPSMBFileManagerPickerViewController : DDPBaseViewController
@property (assign, nonatomic) PickerFileType fileType;
@property (strong, nonatomic) DDPSMBFile *file;
@property (copy, nonatomic) SelectedFileAction selectedFileCallBack;
@end
