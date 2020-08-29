//
//  DDPWebDAVFilePickerViewController.h
//  DDPlay
//
//  Created by JimHuang on 2020/6/9.
//  Copyright © 2020 JimHuang. All rights reserved.
//

#import "DDPBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^SelectedFileAction)(__kindof DDPFile *);

@interface DDPWebDAVFilePickerViewController : DDPBaseViewController
@property (assign, nonatomic) PickerFileType fileType;
@property (strong, nonatomic) DDPWebDAVFile *file;
@property (copy, nonatomic) SelectedFileAction selectedFileCallBack;
@end

NS_ASSUME_NONNULL_END
