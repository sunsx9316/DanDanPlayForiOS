//
//  DDPMainVCItem.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2019/7/27.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import "DDPBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface DDPMainVCItem : DDPBase
@property (strong, nonatomic) UIImage *normalImage;
@property (strong, nonatomic) UIImage *selectedImage;
@property (copy, nonatomic) NSString *vcClassName;
@end

NS_ASSUME_NONNULL_END
