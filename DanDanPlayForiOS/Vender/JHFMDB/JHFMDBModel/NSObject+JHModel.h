//
//  NSObject+JHModel.h
//  JHFMDB
//
//  Created by Developer2 on 2017/11/29.
//  Copyright © 2017年 Developer2. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JHFMDBProtocol<NSObject>
@optional

/**
 主键 多个则为联合主键 默认为jh_defaultPrimaryKey
 
 @return 主键
 */
+ (NSArray <NSString *>*)jh_primaryKeys;

+ (NSDictionary<NSString *, NSString *> *)jh_modelCustomPropertyMapper;
+ (NSArray<NSString *> *)jh_modelPropertyBlacklist;
+ (NSArray<NSString *> *)jh_modelPropertyWhitelist;
+ (NSDictionary<NSString *, id> *)jh_modelContainerPropertyGenericClass;
+ (Class)jh_modelCustomClassForDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)jh_modelCustomWillTransformFromDictionary:(NSDictionary *)dic;
- (BOOL)jh_modelCustomTransformFromDictionary:(NSDictionary *)dic;
- (BOOL)jh_modelCustomTransformToDictionary:(NSMutableDictionary *)dic;
@end

@interface NSObject (JHModel)
+ (instancetype)jh_modelWithJSON:(id)json;
+ (instancetype)jh_modelWithDictionary:(NSDictionary *)dictionary;
- (BOOL)jh_modelSetWithJSON:(id)json;
- (BOOL)jh_modelSetWithDictionary:(NSDictionary *)dic;
- (id)jh_modelToJSONObject;
- (NSData *)jh_modelToJSONData;
- (NSString *)jh_modelToJSONString;
- (id)jh_modelCopy;
- (void)jh_modelEncodeWithCoder:(NSCoder *)aCoder;
- (id)jh_modelInitWithCoder:(NSCoder *)aDecoder;
- (NSUInteger)jh_modelHash;
- (BOOL)jh_modelIsEqual:(id)model;
- (NSString *)jh_modelDescription;
@end

@interface NSArray (JHModel)
+ (NSArray *)jh_modelArrayWithClass:(Class)cls json:(id)json;
@end

@interface NSDictionary (JHModel)
+ (NSDictionary *)jh_modelDictionaryWithClass:(Class)cls json:(id)json;
@end
