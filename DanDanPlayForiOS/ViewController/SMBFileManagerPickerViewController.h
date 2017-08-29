//
//  SMBFileManagerPickerViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/22.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseViewController.h"
#import "LocalFileManagerPickerViewController.h"

@interface SMBFileManagerPickerViewController : BaseViewController
@property (assign, nonatomic) PickerFileType fileType;
@property (strong, nonatomic) JHSMBFile *file;
@property (copy, nonatomic) SelectedFileAction selectedFileCallBack;
@end
