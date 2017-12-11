//
//  JHFMDBHelper.h
//  JHFMDB
//
//  Created by Developer2 on 2017/11/27.
//  Copyright © 2017年 Developer2. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^JHFMDBHelperCompletionAction)(BOOL flag);
typedef void(^JHFMDBHelperFindCompletionAction)(id obj);
typedef void(^JHFMDBHelperFindCollectionCompletionAction)(NSArray *collection);
typedef void(^JHFMDBHelperCountCompletionAction)(UInt64 count);

FOUNDATION_EXPORT NSString *jh_appendPrefix(NSString *key);
FOUNDATION_EXPORT NSString *jh_formatWhereValue(id value);

@interface JHFMDBHelper : NSObject
+ (void)setDbName:(NSString *)name;
+ (void)setPrefix:(NSString *)prefix;
+ (BOOL)deleteSqliteFileWithName:(NSString *)name;
+ (instancetype)shareHelper;

- (NSString *)makePrimaryKeyWhereSQLWithObj:(id)object;

#pragma mark - 增
- (BOOL)saveObject:(id)object
         tableName:(NSString *)tableName;

- (void)saveObject:(id)object
         tableName:(NSString *)tableName
        completion:(JHFMDBHelperCompletionAction)completion;


- (BOOL)saveObjects:(NSArray *)objects
          tableName:(NSString *)tableName;

- (void)saveObjects:(NSArray *)objects
          tableName:(NSString *)tableName
         completion:(JHFMDBHelperCompletionAction)completion;

- (BOOL)saveOrUpdateObject:(id)object
                 tableName:(NSString *)tableName;

- (void)saveOrUpdateObject:(id)object
                 tableName:(NSString *)tableName
                completion:(JHFMDBHelperCompletionAction)completion;

- (BOOL)saveOrUpdateObjects:(NSArray *)objects
                  tableName:(NSString *)tableName;

- (void)saveOrUpdateObjects:(NSArray *)objects
                  tableName:(NSString *)tableName
                 completion:(JHFMDBHelperCompletionAction)completion;


#pragma mark - 删
- (BOOL)deleteFromTable:(NSString *)tableName
              where:(NSString *)where;

- (void)deleteFromTable:(NSString *)tableName
                  where:(NSString *)where
             completion:(JHFMDBHelperCompletionAction)completion;

#pragma mark - 改
- (BOOL)updateObject:(id)object
           tableName:(NSString *)tableName
           updateKeys:(NSArray <NSString *>*)updateKeys
              where:(NSString *)where;

- (void)updateObject:(id)object
           tableName:(NSString *)tableName
           updateKeys:(NSArray <NSString *>*)updateKeys
               where:(NSString *)where
          completion:(JHFMDBHelperCompletionAction)completion;

- (BOOL)updateObjects:(NSArray *)objects
           tableName:(NSString *)tableName
          updateKeys:(NSArray <NSString *>*)updateKeys
               where:(NSString *)where;

- (void)updateObjects:(NSArray *)objects
            tableName:(NSString *)tableName
           updateKeys:(NSArray <NSString *>*)updateKeys
                where:(NSString *)where
           completion:(JHFMDBHelperCompletionAction)completion;


#pragma mark - 查
- (NSArray *)findObjectsFromTable:(NSString *)tableName
                         objClass:(Class)objClass
                            where:(NSString *)where
                        parameter:(NSString *)parameter;

- (void)findObjectsFromTable:(NSString *)tableName
           objClass:(Class)objClass
              where:(NSString *)where
                   parameter:(NSString *)parameter
           completion:(JHFMDBHelperFindCollectionCompletionAction)completion;

- (UInt64)countFromTable:(NSString *)tableName
                   where:(NSString *)where;

- (void)countFromTable:(NSString *)tableName
                   where:(NSString *)where
            completion:(JHFMDBHelperCountCompletionAction)completion;


@end
