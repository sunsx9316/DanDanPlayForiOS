//
//  DDPHTTPResponseSerializer.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHTTPResponseSerializer.h"

@implementation DDPHTTPResponseSerializer

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error {
    
    NSString *contentType = [response.allHeaderFields[@"Content-Type"] isKindOfClass:[NSString class]] ? response.allHeaderFields[@"Content-Type"] : @"";
    
    //xml
    if ([contentType rangeOfString:@"application/xml" options:NSCaseInsensitiveSearch].location != NSNotFound ||
        [contentType rangeOfString:@"text/xml" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        if (data.length > 0) {
            return [NSDictionary dictionaryWithXML:data];
        }
        
        return nil;
    }
    //json
    else if ([contentType rangeOfString:@"application/json" options:NSCaseInsensitiveSearch].location != NSNotFound) {
        id responseObject = nil;
        NSError *serializationError = nil;
        BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
        if (data.length > 0 && !isSpace) {
            responseObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&serializationError];
        }
        else {
            return nil;
        }
        
        if (serializationError) {
            *error = serializationError;
        }
        
        return responseObject;
    }
    
    return [super responseObjectForResponse:response data:data error:error];
}
@end
