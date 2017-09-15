//
//  LinkFileManagerViewController.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/9/15.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "BaseViewController.h"

@interface LinkFileManagerViewController : BaseViewController
@property (strong, nonatomic) JHLinkFile *file;
- (void)refresh;
@end
