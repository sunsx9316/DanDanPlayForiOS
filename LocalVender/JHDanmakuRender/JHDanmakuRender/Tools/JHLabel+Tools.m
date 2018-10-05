//
//  JHLabel+Tools.m
//  JHDanmakuRender
//
//  Created by JimHuang on 2018/5/1.
//

#import "JHLabel+Tools.h"

@implementation _JHLabel (Tools)

- (void)setAttributedString:(NSAttributedString *)attributedString {
#if JH_IOS
    self.attributedText = attributedString;
#else
    self.attributedStringValue = attributedString;
#endif
}

- (NSAttributedString *)attributedString {
#if JH_IOS
    return self.attributedText;
#else
    return self.attributedStringValue;
#endif
}

@end
