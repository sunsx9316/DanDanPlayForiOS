//
//  JHLabel+Tools.h
//  JHDanmakuRender
//
//  Created by JimHuang on 2018/5/1.
//

#import "JHDanmakuDefinition.h"

#if JH_MACOS
#define _JHLabel NSTextField
#else
#define _JHLabel UILabel
#endif

@interface _JHLabel (Tools)

@property (strong, nonatomic) NSAttributedString *attributedString;

@end
