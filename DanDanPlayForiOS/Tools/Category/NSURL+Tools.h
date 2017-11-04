//
//  NSURL+Tools.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/8/19.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Tools)
- (NSURLRelationship)relationshipWithURL:(NSURL *)url;
- (NSString *)relativePathWithBaseURL:(NSURL *)url;
@end
