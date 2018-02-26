//
//  DDPLocalFileManagerPickerViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

typedef void(^SelectedFileAction)(__kindof DDPFile *);

@interface DDPLocalFileManagerPickerViewController : DDPBaseViewController
@property (assign, nonatomic) PickerFileType fileType;
@property (strong, nonatomic) DDPFile *file;
@property (copy, nonatomic) SelectedFileAction selectedFileCallBack;
@end
