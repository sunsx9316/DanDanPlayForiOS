//
//  FilterNetManager.m
//  DanDanPlayForMac
//
//  Created by JimHuang on 16/2/24.
//  Copyright © 2016年 JimHuang. All rights reserved.
//

#import "FilterNetManager.h"
#import <GDataXMLNode.h>

@implementation FilterNetManager
+ (NSURLSessionDataTask *)cloudfilterListWithCompletionHandler:(void(^)(JHFilterCollection *responseObject, NSError *error))completionHandler {
    
#ifdef DEBUG
    NSString *path = @"http://api.acplay.net:8089/config/filter.xml";
#else
    NSString *path = @"https://api.acplay.net/config/filter.xml";
#endif
    
    return [self GETDataWithPath:path parameters:nil completionHandler:^(JHResponse *model) {
        if (model.error) {
            completionHandler(nil, model.error);
        }
        else {
            NSError *err = nil;
            JHFilterCollection *responseObject = [[JHFilterCollection alloc] init];
            responseObject.collection = [NSMutableArray array];
            
            GDataXMLDocument *document=[[GDataXMLDocument alloc] initWithData:model.responseObject encoding:NSUTF8StringEncoding error:&err];
            NSArray *dataArr = [document.rootElement elementsForName:@"FilterItem"];
            for (GDataXMLElement *dataElement in dataArr) {
                
                JHFilter *model = [[JHFilter alloc] init];
                model.content = dataElement.stringValue;
                model.name = [[dataElement attributeForName:@"Name"] stringValue];
                model.isRegex = [[[dataElement attributeForName:@"IsRegex"] stringValue] isEqualToString:@"true"];
                [responseObject.collection addObject:model];
            }
            
            completionHandler(responseObject, err);
        }
    }];
}
@end
