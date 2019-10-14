//
//  DDPPlayerTableCellView.h
//  DDPlayMacPlayer
//
//  Created by JimHuang on 2019/10/13.
//  Copyright © 2019 JimHuang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface DDPPlayerTableCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *label;
@property (nonatomic, assign) BOOL showPoint;

@end

NS_ASSUME_NONNULL_END
