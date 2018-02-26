//
//  DDPHTTPRequestSerializer.m
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import "DDPHTTPRequestSerializer.h"

@implementation DDPHTTPRequestSerializer

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request withParameters:(DDPRequestParameters *)aParameters error:(NSError *__autoreleasing  _Nullable *)error {
    NSParameterAssert(request);
    
    DDPBaseNetManagerSerializerType type = aParameters.serializerType;
    id parameters = aParameters.parameters;
    
    if (type & DDPBaseNetManagerSerializerRequestParseToJSON) {
        
        if ([self.HTTPMethodsEncodingParametersInURI containsObject:[[request HTTPMethod] uppercaseString]]) {
            return [super requestBySerializingRequest:request withParameters:parameters error:error];
        }
        
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        
        [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            if (![request valueForHTTPHeaderField:field]) {
                [mutableRequest setValue:value forHTTPHeaderField:field];
            }
        }];
        
        if (parameters) {
            if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
                [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            }
            
            if ([NSJSONSerialization isValidJSONObject:parameters]) {
                [mutableRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:error]];
            }
        }
        
        return mutableRequest;
    }
    else if (type & DDPBaseNetManagerSerializerRequestParseToXML) {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        
        [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            if (![request valueForHTTPHeaderField:field]) {
                [mutableRequest setValue:value forHTTPHeaderField:field];
            }
        }];
        
        [mutableRequest setValue:@"text/xml,application/xhtml+xml,application/xml" forHTTPHeaderField:@"accept"];
        
        if (parameters) {
            [mutableRequest setHTTPBody:[[NSString stringWithFormat:@"%@", parameters] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        return mutableRequest;
    }
    else {
        NSMutableURLRequest *mutableRequest = [request mutableCopy];
        
        [self.HTTPRequestHeaders enumerateKeysAndObjectsUsingBlock:^(id field, id value, BOOL * __unused stop) {
            if (![request valueForHTTPHeaderField:field]) {
                [mutableRequest setValue:value forHTTPHeaderField:field];
            }
        }];
        
        if (parameters) {
            if (![mutableRequest valueForHTTPHeaderField:@"Content-Type"]) {
                [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            }
            [mutableRequest setHTTPBody:[[NSString stringWithFormat:@"%@", parameters] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        return mutableRequest;
    }
    
    return [super requestBySerializingRequest:request withParameters:parameters error:error];
}

@end
