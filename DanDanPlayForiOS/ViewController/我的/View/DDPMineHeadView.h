//
//  DDPMineHeadView.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2018/10/5.
//  Copyright © 2018 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDPMineHeadView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idLabel;

@property (strong, nonatomic) DDPUser *model;

@end

NS_ASSUME_NONNULL_END
