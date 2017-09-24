//
//  LocalFileManagerPickerViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "JHBaseViewController.h"

typedef void(^SelectedFileAction)(__kindof JHFile *);

@interface LocalFileManagerPickerViewController : JHBaseViewController
@property (assign, nonatomic) PickerFileType fileType;
@property (strong, nonatomic) JHFile *file;
@property (copy, nonatomic) SelectedFileAction selectedFileCallBack;
@end
