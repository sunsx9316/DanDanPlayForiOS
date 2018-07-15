//
//  DDPNetManagerDefine.h
//  DanDanPlayForiOS
//
//  Created by JimHuang on 2017/12/17.
//  Copyright © 2017年 JimHuang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef id(^DDPBatchEditResponseObjAction)(id responseObj);

typedef void(^DDPBatchCompletionAction)(NSArray <DDPBatchResponse *>*responseObjects, NSError *error);

typedef void(^DDPResponseCompletionAction)(__kindof DDPResponse *responseObj);

typedef void(^DDPProgressAction)(float progress);

typedef void(^DDPErrorCompletionAction)(NSError *error);

#define DDP_COLLECTION_RESPONSE_ACTION(object) void(^)(object *collection, NSError *error)

#define DDP_ENTITY_RESPONSE_ACTION(object) void(^)(object *model, NSError *error)




/**
 序列化类型
 
 - DDPBaseNetManagerSerializerRequestNoParse: 请求不格式化
 - DDPBaseNetManagerSerializerRequestParseToJSON: 请求内容格式化为json
 - DDPBaseNetManagerSerializerRequestParseToXML: 请求内容格式化为xml
 - DDPBaseNetManagerSerializerResponseNoParse: 响应不格式化
 - DDPBaseNetManagerSerializerResponseParseToJSON: 响应格式化为json
 - DDPBaseNetManagerSerializerResponseParseToXML: 响应内容格式化为xml
 - DDPBaseNetManagerSerializerNone: 请求体和响应都不格式化
 - DDPBaseNetManagerSerializerTypeJSON: 请求体和响应都格式化为json
 - DDPBaseNetManagerSerializerTypeXML: 请求体和响应都格式化为xml
 */
typedef NS_ENUM(NSUInteger, DDPBaseNetManagerSerializerType) {
    DDPBaseNetManagerSerializerRequestNoParse = 1 << 0,
    DDPBaseNetManagerSerializerRequestParseToJSON = 1 << 1,
    DDPBaseNetManagerSerializerRequestParseToXML = 1 << 2,
    DDPBaseNetManagerSerializerResponseNoParse = 1 << 3,
    DDPBaseNetManagerSerializerResponseParseToJSON = 1 << 4,
    DDPBaseNetManagerSerializerResponseParseToXML = 1 << 5,
    
    DDPBaseNetManagerSerializerNone = DDPBaseNetManagerSerializerRequestNoParse | DDPBaseNetManagerSerializerResponseNoParse,
    DDPBaseNetManagerSerializerTypeJSON = DDPBaseNetManagerSerializerRequestParseToJSON | DDPBaseNetManagerSerializerResponseParseToJSON,
    DDPBaseNetManagerSerializerTypeXML = DDPBaseNetManagerSerializerRequestParseToXML | DDPBaseNetManagerSerializerResponseParseToXML,
};

//typedef NS_ENUM(NSUInteger, DDPHTTPSerializerType) {
//    DDPHTTPSerializerTypeRequest,
//    DDPHTTPSerializerTypeResponse
//};
//
//@protocol DDPHTTPSerializerDelegate<NSObject>
//@optional
//- (DDPBaseNetManagerSerializerType)serializerTypeWithURL:(NSURL *)url type:(DDPHTTPSerializerType)type;
//
//- (void)serializerDidResponseWithURL:(NSURL *)url;
//@end

