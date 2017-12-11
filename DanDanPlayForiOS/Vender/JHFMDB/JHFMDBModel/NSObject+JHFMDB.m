//
//  NSObject+JHFMDB.m
//  JHFMDB
//
//  Created by Developer2 on 2017/11/27.
//  Copyright © 2017年 Developer2. All rights reserved.
//

#import "NSObject+JHFMDB.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "JHClassInfo.h"
@implementation NSObject (JHFMDB)

static char primaryKey = '\0';

- (void)setDefaultPrimaryKey:(NSUInteger)defaultPrimaryKey {
    objc_setAssociatedObject(self, &primaryKey, @(defaultPrimaryKey), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSUInteger)defaultPrimaryKey {
    NSNumber *numer = objc_getAssociatedObject(self, &primaryKey);
    return numer.unsignedIntegerValue;
}

+ (NSArray<NSString *> *)jh_primaryKeys {
    return @[@"defaultPrimaryKey"];
}

#pragma mark - 增
- (BOOL)jh_saveWithTableName:(NSString *)tableName {
    return [[JHFMDBHelper shareHelper] saveObject:self tableName:[self.class jh_tableName:tableName]];
}

- (void)jh_saveObjectWithTableName:(NSString *)tableName completion:(JHFMDBHelperCompletionAction)completion {
    [[JHFMDBHelper shareHelper] saveObject:self tableName:[self.class jh_tableName:tableName] completion:completion];
}

+ (BOOL)jh_saveObjects:(NSArray *)Objects
             tableName:(NSString *)tableName {
    return [[JHFMDBHelper shareHelper] saveObjects:Objects tableName:[self jh_tableName:tableName]];
}

+ (void)jh_saveObjects:(NSArray *)Objects
             tableName:(NSString *)tableName
            completion:(JHFMDBHelperCompletionAction)completion {
    [[JHFMDBHelper shareHelper] saveObjects:Objects tableName:[self jh_tableName:tableName] completion:completion];
}

- (BOOL)jh_saveOrUpdateWithTableName:(NSString *)tableName {
    return [[JHFMDBHelper shareHelper] saveOrUpdateObject:self tableName:[self.class jh_tableName:tableName]];
}

- (void)jh_saveOrUpdateWithTableName:(NSString *)tableName
                          completion:(JHFMDBHelperCompletionAction)completion {
    [[JHFMDBHelper shareHelper] saveOrUpdateObject:self tableName:[self.class jh_tableName:tableName] completion:completion];
}

+ (BOOL)jh_saveOrUpdateObjects:(NSArray *)objects
                         table:(NSString *)tableName {
    return [[JHFMDBHelper shareHelper] saveOrUpdateObjects:objects tableName:[self jh_tableName:tableName]];
}

+ (void)jh_saveOrUpdateObjects:(NSArray *)objects
                         table:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion {
    [[JHFMDBHelper shareHelper] saveOrUpdateObjects:objects tableName:[self jh_tableName:tableName] completion:completion];
}

#pragma mark - 删
- (BOOL)jh_deleteWithTableName:(NSString *)tableName {
    return [self jh_deleteWithTableName:tableName where:nil];
}

- (BOOL)jh_deleteWithTableName:(NSString *)tableName
                         where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    //没有where语句 默认根据主键查询
    else {
        where = [[JHFMDBHelper shareHelper] makePrimaryKeyWhereSQLWithObj:self];
    }
    
    return [[JHFMDBHelper shareHelper] deleteFromTable:[self.class jh_tableName:tableName] where:where];
}

- (void)jh_deleteWithTableName:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion {
    [self jh_deleteWithTableName:tableName completion:completion where:nil];
}

- (void)jh_deleteWithTableName:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion
                         where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    //没有where语句 默认根据主键查询
    else {
        where = [[JHFMDBHelper shareHelper] makePrimaryKeyWhereSQLWithObj:self];
    }
    
    [[JHFMDBHelper shareHelper] jh_deleteWithTableName:[self.class jh_tableName:tableName] completion:completion where:where];
}

#pragma mark - 改
- (BOOL)jh_updateWithTableName:(NSString *)tableName {
    return [self jh_updateWithTableName:tableName updateKeys:nil where:nil];
}

- (BOOL)jh_updateWithTableName:(NSString *)tableName
                         where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    return [self jh_updateWithTableName:tableName updateKeys:nil where:where];
}

- (BOOL)jh_updateWithTableName:(NSString *)tableName
                    updateKeys:(NSArray <NSString *>*)updateKeys
                         where:(NSString *)where,... {
    if (updateKeys.count == 0) {
        updateKeys = [[self jh_modelToJSONObject] allKeys];
    }
    
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    //没有where语句 默认根据主键查询
    else {
        where = [[JHFMDBHelper shareHelper] makePrimaryKeyWhereSQLWithObj:self];
    }
    
    return [[JHFMDBHelper shareHelper] updateObject:self tableName:[self.class jh_tableName:tableName] updateKeys:updateKeys where:where];
}

- (void)jh_updateWithTableName:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion {
    return [self jh_updateWithTableName:tableName completion:completion where:nil];
}

- (void)jh_updateWithTableName:(NSString *)tableName
                    completion:(JHFMDBHelperCompletionAction)completion
                         where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    [self jh_updateWithTableName:tableName updateKeys:nil completion:completion where:where];
}

- (void)jh_updateWithTableName:(NSString *)tableName
                    updateKeys:(NSArray <NSString *>*)updateKeys
                    completion:(JHFMDBHelperCompletionAction)completion
                         where:(NSString *)where,... {
    if (updateKeys.count == 0) {
        NSDictionary *dic = [self jh_modelToJSONObject];
        updateKeys = dic.allKeys;
    }
    
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    //没有where语句 默认根据主键查询
    else {
        where = [[JHFMDBHelper shareHelper] makePrimaryKeyWhereSQLWithObj:self];
    }
    
    [[JHFMDBHelper shareHelper] updateObject:self tableName:[self.class jh_tableName:tableName] updateKeys:updateKeys where:where completion:completion];
}

+ (BOOL)jh_updateWithTableName:(NSString *)tableName
                    updateKeys:(NSArray <NSString *>*)updateKeys
                       objects:(NSArray *)objects
                         where:(NSString *)where,... {
    if (objects.count == 0) return NO;
    
    if (updateKeys.count == 0) {
        NSDictionary *dic = [self jh_modelToJSONObject];
        updateKeys = dic.allKeys;
    }
    
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    //没有where语句 默认根据主键查询
    else {
        where = [[JHFMDBHelper shareHelper] makePrimaryKeyWhereSQLWithObj:self];
    }
    
    
    return [[JHFMDBHelper shareHelper] updateObjects:objects tableName:[self jh_tableName:tableName] updateKeys:updateKeys where:where];
}

+ (void)jh_updateWithTableName:(NSString *)tableName
                    updateKeys:(NSArray <NSString *>*)updateKeys
                       objects:(NSArray *)objects
                    completion:(JHFMDBHelperCompletionAction)completion
                         where:(NSString *)where,... {
    if (objects.count == 0) {
        if (completion) {
            completion(NO);
        }
        return;
    }
    
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    //没有where语句 默认根据主键查询
    else {
        where = [[JHFMDBHelper shareHelper] makePrimaryKeyWhereSQLWithObj:self];
    }
    
    if (updateKeys.count == 0) {
        NSDictionary *dic = [self jh_modelToJSONObject];
        updateKeys = dic.allKeys;
    }
    
    return [[JHFMDBHelper shareHelper] updateObjects:objects tableName:[self jh_tableName:tableName] updateKeys:updateKeys where:where completion:completion];
}

#pragma mark - 查
+ (id)jh_findFromTable:(NSString *)tableName
                 where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    return [self jh_findFromTable:tableName limit:1 orderBy:nil desc:NO where:where].firstObject;
}

+ (void)jh_findFromTable:(NSString *)tableName
              completion:(JHFMDBHelperFindCompletionAction)completion
                   where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    [self jh_findFromTable:tableName limit:1 orderBy:nil desc:NO completion:completion where:where];
}

+ (NSArray *)jh_findAllFromTable:(NSString *)tableName
                           where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    return [[JHFMDBHelper shareHelper] findObjectsFromTable:[self jh_tableName:tableName] objClass:self where:where parameter:nil];
}

+ (void)jh_findAllFromTable:(NSString *)tableName
                 completion:(JHFMDBHelperFindCollectionCompletionAction)completion
                      where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    [[JHFMDBHelper shareHelper] findObjectsFromTable:[self jh_tableName:tableName] objClass:self where:where parameter:nil completion:completion];
    
}

+ (NSArray *)jh_findFromTable:(NSString *)tableName
                        limit:(SInt64)limit
                      orderBy:(NSString *)orderBy
                         desc:(BOOL)desc
                        where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    return [self jh_findFromTable:tableName page:0 limit:limit orderBy:orderBy desc:desc where:where];
}

+ (NSArray *)jh_findFromTable:(NSString *)tableName
                         page:(NSUInteger)page
                        limit:(SInt64)limit
                      orderBy:(NSString *)orderBy
                         desc:(BOOL)desc
                        where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    NSMutableString *parameter = [[NSMutableString alloc] init];
    if (orderBy.length) {
        [parameter appendFormat:@"order by %@ %@", jh_appendPrefix(orderBy), desc ? @"desc" : @"asc"];
    }
    
    [parameter appendFormat:@" limit %llu,%lld", page * limit, limit];
    
    return [[JHFMDBHelper shareHelper] findObjectsFromTable:[self jh_tableName:tableName] objClass:self where:where parameter:parameter];
}

+ (void)jh_findFromTable:(NSString *)tableName
                   limit:(SInt64)limit
                 orderBy:(NSString *)orderBy
                    desc:(BOOL)desc
              completion:(JHFMDBHelperFindCollectionCompletionAction)completion
                   where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    return [self jh_findFromTable:tableName page:0 limit:limit orderBy:orderBy desc:desc completion:completion where:where];
}

+ (void)jh_findFromTable:(NSString *)tableName
                    page:(NSUInteger)page
                   limit:(SInt64)limit
                 orderBy:(NSString *)orderBy
                    desc:(BOOL)desc
              completion:(JHFMDBHelperFindCollectionCompletionAction)completion
                   where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    NSMutableString *parameter = [[NSMutableString alloc] init];
    if (orderBy.length) {
        [parameter appendFormat:@"order by %@ %@", jh_appendPrefix(orderBy), desc ? @"desc" : @"asc"];
    }
    
    [parameter appendFormat:@" limit %llu,%lld", page * limit, limit];
    
    return [[JHFMDBHelper shareHelper] findObjectsFromTable:[self jh_tableName:tableName] objClass:self where:where parameter:parameter completion:completion];
}

+ (UInt64)jh_countFromTable:(NSString *)tableName
                      where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    return [[JHFMDBHelper shareHelper] countFromTable:[self jh_tableName:tableName] where:where];
}

+ (void)jh_countFromTable:(NSString *)tableName
               completion:(JHFMDBHelperCountCompletionAction)completion
                    where:(NSString *)where,... {
    if (where) {
        va_list ap;
        va_start(ap, where);
        where = [[NSString alloc] initWithFormat:where arguments:ap];
        va_end(ap);
    }
    
    [[JHFMDBHelper shareHelper] countFromTable:[self jh_tableName:tableName] where:where completion:completion];
}

#pragma mark - 私有方法
+ (NSString *)jh_tableName:(NSString *)tableName {
    return tableName.length ? tableName : NSStringFromClass(self);
}

@end
