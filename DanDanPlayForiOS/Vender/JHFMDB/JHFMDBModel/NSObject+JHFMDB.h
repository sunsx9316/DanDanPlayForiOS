//
//  NSObject+JHFMDB.h
//  JHFMDB
//
//  Created by Developer2 on 2017/11/27.
//  Copyright © 2017年 Developer2. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JHFMDBHelper.h"
#import "NSObject+JHModel.h"

@interface NSObject (JHFMDB)<JHFMDBProtocol>
@property (nonatomic, assign) NSUInteger defaultPrimaryKey;

#pragma mark - 增

/**
 保存对象
 
 @param tableName 表名
 @return 是否保存成功
 */
- (BOOL)jh_saveWithTableName:(NSString *)tableName;


/**
 保存对象
 
 @param tableName 表名
 @param completion 完成回调
 */
- (void)jh_saveObjectWithTableName:(NSString *)tableName
                        completion:(JHFMDBHelperCompletionAction)completion;

/**
 批量保存对象

 @param Objects 对象数组 必须是同一种类型
 @param tableName 表名
 @return 保存是否成功
 */
+ (BOOL)jh_saveObjects:(NSArray *)Objects
             tableName:(NSString *)tableName;

/**
 异步批量保存对象

 @param Objects 对象数组 必须是同一种类型
 @param tableName 表名
 @param completion 完成回调
 */
+ (void)jh_saveObjects:(NSArray *)Objects
             tableName:(NSString *)tableName
            completion:(JHFMDBHelperCompletionAction)completion;

/**
 主键存在更新否则保存
 
 @param tableName 表名
 @return 是否成功
 */
- (BOOL)jh_saveOrUpdateWithTableName:(NSString *)tableName;

/**
 主键存在更新否则保存
 
 @param tableName 表名
 @param completion 完成回调
 */
- (void)jh_saveOrUpdateWithTableName:(NSString *)tableName
                          completion:(JHFMDBHelperCompletionAction)completion;

/**
 批量保存或更新
 
 @param objects 对象
 @param tableName 表名
 @return 完成回调
 */
+ (BOOL)jh_saveOrUpdateObjects:(NSArray *)objects
                         table:(NSString *)tableName;

/**
 批量保存或更新
 
 @param objects 对象
 @param tableName 表名
 @param completion 完成回调
 */
+ (void)jh_saveOrUpdateObjects:(NSArray *)objects
                         table:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion;

#pragma mark - 删

/**
 根据对象的主键删除对象
 
 @param tableName 表名
 @return 是否成功
 */
- (BOOL)jh_deleteWithTableName:(NSString *)tableName;

/**
 删除对象
 
 @param tableName 表名
 @param where where查询
 @return 是否成功
 */
- (BOOL)jh_deleteWithTableName:(NSString *)tableName
                         where:(NSString *)where,...;

/**
 删除对象
 
 @param tableName 表名
 @param completion 完成回调
 */
- (void)jh_deleteWithTableName:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion;

/**
 删除对象
 
 @param tableName 表名
 @param completion 完成回调
 @param where where查询语句
 */
- (void)jh_deleteWithTableName:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion
                         where:(NSString *)where,...;

#pragma mark - 改

/**
 更新对象
 
 @param tableName 表名
 @return 更新是否成功
 */
- (BOOL)jh_updateWithTableName:(NSString *)tableName;

/**
 更新对象
 
 @param tableName 表名
 @param where where查询语句
 @return 更新是否成功
 */
- (BOOL)jh_updateWithTableName:(NSString *)tableName
                         where:(NSString *)where,...;

/**
 更新对象
 
 @param tableName 表名
 @param updateKeys 需要更新的属性
 @param where where查询语句
 @return 更新是否成功
 */
- (BOOL)jh_updateWithTableName:(NSString *)tableName
                    updateKeys:(NSArray <NSString *>*)updateKeys
                         where:(NSString *)where,...;

/**
 更新对象
 
 @param tableName 表名
 @param completion 完成回调
 */
- (void)jh_updateWithTableName:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion;

/**
 更新对象
 
 @param tableName 表名
 @param completion 完成回调
 @param where where查询语句
 */
- (void)jh_updateWithTableName:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion
                         where:(NSString *)where,...;

/**
 更新对象
 
 @param tableName 表名
 @param updateKeys 需要更新的属性
 @param completion 完成回调
 @param where where查询语句
 */
- (void)jh_updateWithTableName:(NSString *)tableName
                    updateKeys:(NSArray <NSString *>*)updateKeys
                    completion:(JHFMDBHelperCompletionAction)completion
                         where:(NSString *)where,...;

/**
 批量更新对象

 @param tableName 表名
 @param updateKeys 需要更新的属性
 @param objects 对象数组
 @param where where语句
 @return 是否更新成功
 */
+ (BOOL)jh_updateWithTableName:(NSString *)tableName
                    updateKeys:(NSArray <NSString *>*)updateKeys
                       objects:(NSArray *)objects
                         where:(NSString *)where,...;

/**
 异步批量更新对象

 @param tableName 表名
 @param updateKeys 需要更新的属性
 @param objects 对象数组
 @param completion where语句
 @param where 否更新成功
 */
+ (void)jh_updateWithTableName:(NSString *)tableName
                    updateKeys:(NSArray <NSString *>*)updateKeys
                       objects:(NSArray *)objects
                    completion:(JHFMDBHelperCompletionAction)completion
                         where:(NSString *)where,...;

#pragma mark - 查

/**
 查询单个对象
 
 @param tableName 表名
 @param where where查询语句
 @return 对象
 */
+ (instancetype)jh_findFromTable:(NSString *)tableName
                           where:(NSString *)where,...;

/**
 异步查询对象
 
 @param tableName 表名
 @param completion 完成回调
 @param where where查询语句
 */
+ (void)jh_findFromTable:(NSString *)tableName
              completion:(JHFMDBHelperFindCompletionAction)completion
                   where:(NSString *)where,...;

/**
 查询所有对象

 @param tableName 表名
 @param where where语句
 @return 所有对象
 */
+ (NSArray *)jh_findAllFromTable:(NSString *)tableName
                           where:(NSString *)where,...;

/**
 异步查询所有对象

 @param tableName 表名
 @param completion 完成回调
 @param where where语句
 */
+ (void)jh_findAllFromTable:(NSString *)tableName
                 completion:(JHFMDBHelperFindCollectionCompletionAction)completion
                      where:(NSString *)where,...;

/**
 查询对象

 @param tableName 表名
 @param limit 查询数量
 @param orderBy 排序键
 @param desc 升序NO 降序YES
 @param where where语句
 @return 查询对象
 */
+ (NSArray *)jh_findFromTable:(NSString *)tableName
                        limit:(SInt64)limit
                      orderBy:(NSString *)orderBy
                         desc:(BOOL)desc
                        where:(NSString *)where,...;

/**
 分页查询

 @param tableName 表名
 @param page 分页
 @param limit 分页数
 @param orderBy 排序键
 @param desc 升序NO 降序YES
 @param where where语句
 @return 查询对象
 */
+ (NSArray *)jh_findFromTable:(NSString *)tableName
                        page:(NSUInteger)page
                        limit:(SInt64)limit
                      orderBy:(NSString *)orderBy
                         desc:(BOOL)desc
                        where:(NSString *)where,...;

/**
 异步分页查询

 @param tableName 表名
 @param page 分页
 @param limit 分页数
 @param orderBy 排序键
 @param desc 升序NO 降序YES
 @param completion 完成回调
 @param where where语句
 */
+ (void)jh_findFromTable:(NSString *)tableName
                         page:(NSUInteger)page
                        limit:(SInt64)limit
                      orderBy:(NSString *)orderBy
                         desc:(BOOL)desc
                   completion:(JHFMDBHelperFindCollectionCompletionAction)completion
                        where:(NSString *)where,...;

/**
 异步查询对象

 @param tableName 表名
 @param limit 查询数量
 @param orderBy 排序键
 @param desc 升序NO 降序YES
 @param completion 完成回调
 @param where where语句
 */
+ (void)jh_findFromTable:(NSString *)tableName
                   limit:(SInt64)limit
                 orderBy:(NSString *)orderBy
                    desc:(BOOL)desc
              completion:(JHFMDBHelperFindCollectionCompletionAction)completion
                   where:(NSString *)where,...;

/**
 查询个数
 
 @param tableName 表名
 @param where where查询语句
 @return 个数
 */
+ (UInt64)jh_countFromTable:(NSString *)tableName
                      where:(NSString *)where,...;

/**
 查询个数
 
 @param tableName 表名
 @param completion 完成回调
 @param where here查询语句
 */
+ (void)jh_countFromTable:(NSString *)tableName
               completion:(JHFMDBHelperCountCompletionAction)completion
                    where:(NSString *)where,...;

@end
