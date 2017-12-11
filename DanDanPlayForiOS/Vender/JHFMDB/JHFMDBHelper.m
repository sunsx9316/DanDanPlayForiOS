//
//  JHFMDBHelper.m
//  JHFMDB
//
//  Created by Developer2 on 2017/11/27.
//  Copyright © 2017年 Developer2. All rights reserved.
//

#import "JHFMDBHelper.h"
#import "FMDB.h"
#import "NSObject+JHFMDB.h"
#import "JHClassInfo.h"

#define jh_sql_text @"text" //数据库的字符类型
#define jh_sql_real @"real" //数据库的浮点类型
#define jh_sql_integer @"integer" //数据库的整数类型
#define jh_object_flag @"jh_object:"

#define jh_dbPath(name) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:name]

#define jh_debug(...) NSLog(__VA_ARGS__)

@interface JHFMDBHelper ()
/**
 数据库队列
 */
@property (nonatomic, strong) FMDatabaseQueue *queue;
@property (nonatomic, copy) NSString *dbName;
@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

NS_INLINE NSString *jh_sqlType(JHEncodingType type) {
    switch (type) {
        case JHEncodingTypeBool:
        case JHEncodingTypeInt8:
        case JHEncodingTypeUInt8:
        case JHEncodingTypeInt16:
        case JHEncodingTypeUInt16:
        case JHEncodingTypeInt32:
        case JHEncodingTypeUInt32:
        case JHEncodingTypeInt64:
        case JHEncodingTypeUInt64:
            return jh_sql_integer;
        case JHEncodingTypeFloat:
        case JHEncodingTypeDouble:
        case JHEncodingTypeLongDouble:
            return jh_sql_real;
        default:
            return jh_sql_text;
    }
}

NS_INLINE NSString *jh_sqlTypeWithObj(id obj) {
    if ([obj isKindOfClass:[NSNumber class]]) {
        NSNumber *number = obj;
        return jh_sqlType(JHEncodingGetType(number.objCType));
    }
    return jh_sql_text;
}

NS_INLINE NSString *jh_deletePrefix(NSString *key) {
    NSString *prefix = [JHFMDBHelper shareHelper].prefix;
    if (key.length < prefix.length) return key;
    return [key stringByReplacingCharactersInRange:NSMakeRange(0, prefix.length) withString:@""];
}

NS_INLINE NSString *jh_formatSaveValue(id value) {
    if ([value isKindOfClass:[NSString class]] == NO && [value isKindOfClass:[NSNumber class]] == NO) {
        return [NSString stringWithFormat:@"%@%@", jh_object_flag, [value jh_modelToJSONString]];
    }
    return value;
}

NSString *jh_appendPrefix(NSString *key) {
    return [[JHFMDBHelper shareHelper].prefix stringByAppendingFormat:@"%@", key];
}

NSString *jh_formatWhereValue(id value) {
    if ([value isKindOfClass:[NSString class]]) {
        return [NSString stringWithFormat:@"'%@'", value];
    }
    
    return value;
}

static NSDictionary *jh_additionData() {
    //数据库版本 方便以后迁移
    return @{@"db_version" : @1};
}

static NSArray *jh_defaultBlackList() {
    return @[@"superclass", @"debugDescription", @"description", @"hash"];
}

@implementation JHFMDBHelper
{
    dispatch_queue_t _dispatchQueue;
}

+ (instancetype)shareHelper {
    static dispatch_once_t onceToken;
    static JHFMDBHelper *helper = nil;
    dispatch_once(&onceToken, ^{
        helper = [[JHFMDBHelper alloc] init];
        helper.dbName = @"JHFMDBHelper.db";
        helper.prefix = @"jh_";
    });
    return helper;
}

- (instancetype)init {
    if (self = [super init]) {
        _dispatchQueue = dispatch_queue_create("jh_fmdb_queue", nil);
    }
    return self;
}

- (void)dealloc {
    [self.queue close];
}

+ (void)setDbName:(NSString *)name {
    if (name.length) {
        [[self shareHelper] setDbName:name];
    }
}

+ (void)setPrefix:(NSString *)prefix {
    if (prefix) {
        [[self shareHelper] setPrefix:prefix];
    }
}

+ (BOOL)deleteSqliteFileWithName:(NSString *)name {
    
    if (name.length == 0) {
        name = [[self shareHelper] dbName];
    }
    
    NSString *filePath = jh_dbPath(name);
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSError *error;
    if ([file_manager fileExistsAtPath:filePath]) {
        [file_manager removeItemAtPath:filePath error:&error];
    }
    
    return !!error;
}

#pragma mark -
- (BOOL)saveObject:(id)object
         tableName:(NSString *)tableName {
    //建表成功
    if ([self autoCreateTableIfTableNoExistsWithTabelName:tableName obj:object]) {
        NSArray *values = nil;
        NSString *sql = [self makeSaveSQLWithObj:object table:tableName toValues:&values];
        
        __block BOOL flag = NO;
        [self inDatabase:^(FMDatabase *db) {
            flag = [db executeUpdate:sql withArgumentsInArray:values];
        }];
        
        return flag;
    }
    
    return NO;
}

- (void)saveObject:(id)object tableName:(NSString *)tableName completion:(JHFMDBHelperCompletionAction)completion {
    dispatch_async(_dispatchQueue, ^{
        BOOL flag = [self saveObject:object tableName:tableName];
        if (completion) {
            completion(flag);
        }
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (BOOL)saveObjects:(NSArray *)objects
          tableName:(NSString *)tableName {
    if ([self autoCreateTableIfTableNoExistsWithTabelName:tableName obj:objects.firstObject]) {
        __block BOOL flag = NO;
        [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
            [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSArray *values = nil;
                NSString *sql = [self makeSaveSQLWithObj:obj table:tableName toValues:&values];
                flag = [db executeUpdate:sql withArgumentsInArray:values];
                if (flag == NO) {
                    *stop = YES;
                    *rollback = YES;
                }
            }];
        }];
        return flag;
    }
    
    return NO;
}

- (void)saveObjects:(NSArray *)objects
          tableName:(NSString *)tableName
         completion:(JHFMDBHelperCompletionAction)completion {
    dispatch_async(_dispatchQueue, ^{
        BOOL flag = [self saveObjects:objects tableName:tableName];
        if (completion) {
            completion(flag);
        }
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (BOOL)saveOrUpdateObject:(id)object
                 tableName:(NSString *)tableName {
    if (tableName.length == 0 || object == nil) return NO;
    
    //建表成功
    if ([self autoCreateTableIfTableNoExistsWithTabelName:tableName obj:object]) {
        //主键查询语句
        NSString *sql = [self makePrimaryKeyWhereSQLWithObj:object];
        if (sql.length) {
            NSInteger count = [self countFromTable:tableName where:sql];
            //已经保存 则更新
            if (count) {
                NSDictionary *dic = [object jh_modelToJSONObject];
                return [self updateObject:object tableName:tableName updateKeys:dic.allKeys where:sql];
            }
            else {
                return [self saveObject:object tableName:tableName];
            }
        }
        else {
            return [self saveObject:object tableName:tableName];
        }
    }
    
    return NO;
}

- (void)saveOrUpdateObject:(id)object
                 tableName:(NSString *)tableName
                completion:(JHFMDBHelperCompletionAction)completion {
    dispatch_async(_dispatchQueue, ^{
        BOOL flag = [self saveOrUpdateObject:object tableName:tableName];
        if (completion) {
            completion(flag);
        }
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (BOOL)saveOrUpdateObjects:(NSArray *)objects
                  tableName:(NSString *)tableName {
    if (tableName.length == 0 || objects.count == 0) {
        return NO;
    }
    
    //建表成功
    if ([self autoCreateTableIfTableNoExistsWithTabelName:tableName obj:objects.firstObject]) {
        __block BOOL flag = NO;
        [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (id saveObj in objects) {
                //主键查询语句
                NSString *sql = [self makePrimaryKeyWhereSQLWithObj:saveObj];
                
                //保存操作
                BOOL(^saveAction)(id, FMDatabase *) = ^(id aObj, FMDatabase *aDB){
                    NSArray *values = nil;
                    NSString *saveSql = [self makeSaveSQLWithObj:aObj table:tableName toValues:&values];

                    return [aDB executeUpdate:saveSql withArgumentsInArray:values];
                };
                
                if (sql.length) {
                    sql = [self makeCountSQLWithTable:tableName where:sql];
                    __block NSUInteger count = 0;
                    [db executeStatements:sql withResultBlock:^int(NSDictionary * _Nonnull resultsDictionary) {
                        count = [resultsDictionary.allValues.firstObject integerValue];
                        return 0;
                    }];
                    
                    //查询当前对象是否保存 保存则更新 否则直接保存
                    if (count) {
                        NSDictionary *dic = [saveObj jh_modelToJSONObject];
                        
                        NSArray *values = nil;
                        
                        sql = [self makeUpdateSQLWithObj:saveObj table:tableName updateKeys:dic.allKeys where:[self makePrimaryKeyWhereSQLWithObj:saveObj] toValues:&values];
                        
                        jh_debug(@"更新 %@", sql);
                        flag = [db executeUpdate:sql withArgumentsInArray:values];
                        if (flag == NO) {
                            break;
                        }
                    }
                    else {
                        flag = saveAction(saveObj, db);
                        
                        if (flag == NO) {
                            break;
                        }
                    }
                }
                else {
                    flag = saveAction(saveObj, db);
                    if (flag == NO) {
                        break;
                    }
                }
            }
            
            if (flag == NO) {
                *rollback = YES;
            }
        }];
        
        return flag;
    }
    
    return NO;
}

- (void)saveOrUpdateObjects:(NSArray *)objects
                  tableName:(NSString *)tableName
                 completion:(JHFMDBHelperCompletionAction)completion {
    dispatch_async(_dispatchQueue, ^{
        BOOL flag = [self saveOrUpdateObject:objects tableName:tableName];
        if (completion) {
            completion(flag);
        }
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark -
- (BOOL)deleteFromTable:(NSString *)tableName
                  where:(NSString *)where {
    if (tableName.length == 0 || where.length == 0) return NO;
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@", tableName, where];
    jh_debug(@"删除 %@", sql);
    
    __block BOOL flag = NO;
    [self inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql];
    }];
    
    return flag;
}

- (void)deleteFromTable:(NSString *)tableName
                  where:(NSString *)where
             completion:(JHFMDBHelperCompletionAction)completion {
    dispatch_async(_dispatchQueue, ^{
        BOOL flag = [self deleteFromTable:tableName where:where];
        if (completion) {
            completion(flag);
        }
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark -

- (BOOL)updateObject:(id)object
           tableName:(NSString *)tableName
          updateKeys:(NSArray <NSString *>*)updateKeys
               where:(NSString *)where {
    if (tableName.length == 0 || updateKeys.count == 0 || where.length == 0) return NO;
    
    NSArray *values = nil;
    NSString *sql = [self makeUpdateSQLWithObj:object table:tableName updateKeys:updateKeys where:where toValues:&values];
    
    jh_debug(@"更新 %@", sql);
    
    __block BOOL flag = NO;
    [self inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql withArgumentsInArray:values];
    }];
    
    return flag;
}

- (void)updateObject:(id)object
           tableName:(NSString *)tableName
          updateKeys:(NSArray <NSString *>*)updateKeys
               where:(NSString *)where
          completion:(JHFMDBHelperCompletionAction)completion {
    dispatch_async(_dispatchQueue, ^{
        BOOL flag = [self updateObject:object tableName:tableName updateKeys:updateKeys where:where];
        if (completion) {
            completion(flag);
        }
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (BOOL)updateObjects:(NSArray *)objects
            tableName:(NSString *)tableName
           updateKeys:(NSArray <NSString *>*)updateKeys
                where:(NSString *)where {
    __block BOOL flag = NO;
    [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
        [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *values = nil;
            NSString *sql = [self makeSaveSQLWithObj:obj table:tableName toValues:&values];
            flag = [db executeUpdate:sql withArgumentsInArray:values];
            if (flag == NO) {
                *stop = YES;
                *rollback = YES;
            }
        }];
    }];
    return flag;
}

- (void)updateObjects:(NSArray *)objects
            tableName:(NSString *)tableName
           updateKeys:(NSArray <NSString *>*)updateKeys
                where:(NSString *)where
           completion:(JHFMDBHelperCompletionAction)completion {
    dispatch_async(_dispatchQueue, ^{
        BOOL flag = [self updateObjects:objects tableName:tableName updateKeys:updateKeys where:where];
        if (completion) {
            completion(flag);
        }
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

#pragma mark -
- (NSArray *)findObjectsFromTable:(NSString *)tableName
                         objClass:(Class)objClass
                            where:(NSString *)where
                        parameter:(NSString *)parameter {
    if (tableName.length == 0 || objClass == nil) return nil;
    
    if ([self cheakTableIsExist:tableName]) {
        NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"select * from %@", tableName];
        
        if (where.length) {
            [sql appendFormat:@" where %@", where];
        }
        
        if (parameter.length) {
            [sql appendFormat:@" %@", parameter];
        }
        
        jh_debug(@"查找 %@", sql);
        
        __block NSMutableArray *resultArr = [NSMutableArray array];
        [self inDatabase:^(FMDatabase *db) {
            FMResultSet *result = [db executeQuery:sql];
            while (result.next) {
                NSDictionary <NSString *, id>*dic = result.resultDictionary;
                NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
                NSArray <NSString *>*additionKeys = jh_additionData().allKeys;
                [dic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    NSString *aKey = jh_deletePrefix(key);
                    //去掉框架添加的key
                    if (aKey.length && [additionKeys containsObject:aKey] == NO) {
                        if ([obj isKindOfClass:[NSString class]] && [obj hasPrefix:jh_object_flag]) {
                            NSError *err = nil;
                            NSString *json = [obj substringFromIndex:jh_object_flag.length];
                            id value = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&err];
                            if (err) {
                                mDic[aKey] = obj;
                            }
                            else {
                                mDic[aKey] = value;
                            }
                        }
                        else {
                            mDic[aKey] = obj;
                        }
                    }
                }];
                
                [resultArr addObject:[objClass jh_modelWithDictionary:mDic]];
            }
            
            [result close];
        }];
        return resultArr;
    }
    else {
        return @[];
    }
}

- (void)findObjectsFromTable:(NSString *)tableName
                    objClass:(Class)objClass
                       where:(NSString *)where
                   parameter:(NSString *)parameter
                  completion:(JHFMDBHelperFindCollectionCompletionAction)completion {
    dispatch_async(_dispatchQueue, ^{
        NSArray *objs = [self findObjectsFromTable:tableName objClass:objClass where:where parameter:parameter];
        if (completion) {
            completion(objs);
        }
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}

- (UInt64)countFromTable:(NSString *)tableName
                   where:(NSString *)where {
    if (tableName.length == 0) {
        return 0;
    }
    
    NSString *sql = [self makeCountSQLWithTable:tableName where:where];
    
    jh_debug(@"查询个数：%@", sql);
    __block NSUInteger count = 0;
    [self inDatabase:^(FMDatabase *db) {
        [db executeStatements:sql withResultBlock:^int(NSDictionary * _Nonnull resultsDictionary) {
            count = [resultsDictionary.allValues.firstObject integerValue];
            return 0;
        }];
    }];
    
    return count;
}

- (void)countFromTable:(NSString *)tableName
                 where:(NSString *)where
            completion:(JHFMDBHelperCountCompletionAction)completion {
    dispatch_async(_dispatchQueue, ^{
        UInt64 count = [self countFromTable:tableName where:where];
        if (completion) {
            completion(count);
        }
        dispatch_semaphore_signal(self.semaphore);
    });
    
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}


#pragma mark - 私有方法
- (void)inDatabase:(void (^)(FMDatabase *db))block{
    if (block == nil) return;
    
    [self.queue inDatabase:block];
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block{
    if (block == nil) return;
    
    [self.queue inTransaction:block];
}

- (BOOL)cheakTableIsExist:(NSString *)tableName {
    if (tableName.length == 0) {
        return NO;
    }
    
    __block BOOL flag = NO;
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        flag = [db tableExists:tableName];
    }];
    return flag;
}

- (BOOL)creatTable:(NSString *)tableName obj:(id<JHFMDBProtocol>)obj {
    //建表
    __block BOOL flag = NO;
    [self inDatabase:^(FMDatabase *db) {
        NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"create table if not exists %@ (", tableName];
        JHClassInfo *info = [JHClassInfo classInfoWithClass:[obj class]];
        //没有属性
        if (info.propertyInfos.count == 0) {
            flag = NO;
            return;
        }
        
        NSArray *primaryKeys = [[obj class] jh_primaryKeys];
        
        NSArray<NSString *> *blackList = ^NSArray *{
            if ([obj.class respondsToSelector:@selector(jh_modelPropertyBlacklist)]) {
                return [[obj.class jh_modelPropertyBlacklist] arrayByAddingObjectsFromArray:jh_defaultBlackList()];
            }
            
            return jh_defaultBlackList();
        }();
        
        NSArray<NSString *> *whiteList = ^NSArray *{
            if ([obj.class respondsToSelector:@selector(jh_modelPropertyWhitelist)]) {
                return [obj.class jh_modelPropertyWhitelist];
            }
            return nil;
        }();
        
        NSDictionary *map = ^NSDictionary *{
            if ([obj.class respondsToSelector:@selector(jh_modelCustomPropertyMapper)]) {
                return [obj.class jh_modelCustomPropertyMapper];
            }
            return nil;
        }();
        
        [info.propertyInfos enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, JHClassPropertyInfo * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSString *mapKey = map[key] ? map[key] : key;
            //优先拼接白名单
            if (whiteList.count) {
                if ([whiteList containsObject:key]) {
                    [sql appendFormat:@"%@ %@,", jh_appendPrefix(mapKey), jh_sqlType(JHEncodingGetType(obj.typeEncoding.UTF8String))];
                }
            }
            //不包含在黑名单内 进行拼接
            else if ([blackList containsObject:key] == NO) {
                [sql appendFormat:@"%@ %@,", jh_appendPrefix(mapKey), jh_sqlType(JHEncodingGetType(obj.typeEncoding.UTF8String))];
            }
        }];
        
        NSDictionary *additionData = jh_additionData();
        [additionData enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [sql appendFormat:@"%@ %@,", jh_appendPrefix(key), jh_sqlTypeWithObj(obj)];
        }];
        
        //包含主键
        if (primaryKeys.count) {
            //默认主键 加上自增属性
            if (primaryKeys.count == 1 && [primaryKeys containsObject:NSStringFromSelector(@selector(defaultPrimaryKey))]) {
                [sql appendFormat:@"%@ integer primary key autoincrement);", jh_appendPrefix(NSStringFromSelector(@selector(defaultPrimaryKey)))];
            }
            else {
                NSMutableString *primaryKeyStr = [[NSMutableString alloc] initWithString:@"primary key ("];
                [primaryKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [primaryKeyStr appendFormat:@"%@,", jh_appendPrefix(obj)];
                }];
                //删除最后的","
                [primaryKeyStr deleteCharactersInRange:NSMakeRange(primaryKeyStr.length - 1, 1)];
                [primaryKeyStr appendString:@")"];
                [sql appendFormat:@"%@);", primaryKeyStr];
            }
        }
        else {
            //删除最后的","
            [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
            [sql appendString:@");"];
        }
        
        jh_debug(@"创建表 %@", sql);
        flag = [db executeUpdate:sql];
    }];
    
    return flag;
}

- (BOOL)autoCreateTableIfTableNoExistsWithTabelName:(NSString *)tableName obj:(id<JHFMDBProtocol>)obj {
    if (tableName.length == 0 || obj == nil) {
        return NO;
    }
    
    if ([self cheakTableIsExist:tableName] == NO) {
        return [self creatTable:tableName obj:obj];
    }
    return YES;
}

- (NSString *)makeSaveSQLWithObj:(id)object table:(NSString *)tableName toValues:(NSArray **)toValues {
    NSDictionary *dic = [object jh_modelToJSONObject];
    if (dic.count == 0) return @"";
    
    //加上附加参数
    dic = ({
        NSMutableDictionary *aDic = dic.mutableCopy;
        [aDic addEntriesFromDictionary:jh_additionData()];
        aDic;
    });
    
    NSArray <NSString *>*keys = dic.allKeys;
    NSMutableArray *values = dic.allValues.mutableCopy;
    [values enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        values[idx] = jh_formatSaveValue(obj);
    }];
    
    if (toValues) {
        *toValues = values;
    }
    NSMutableString *sql = [[NSMutableString alloc] init];
    [sql appendFormat:@"insert into %@(", tableName];
    [keys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sql appendFormat:@"%@,", jh_appendPrefix(obj)];
    }];
    //去掉最后一个","
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    [sql appendString:@") values("];
    
    [values enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sql appendString:@"?,"];
    }];
    //去掉最后一个","
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    [sql appendString:@");"];
    
    jh_debug(@"插入 %@", sql);
    return sql;
}

- (NSString *)makeUpdateSQLWithObj:(id)object
                             table:(NSString *)tableName
                        updateKeys:(NSArray <NSString *>*)updateKeys
                             where:(NSString *)where
                          toValues:(NSArray **)toValues {
    if (updateKeys.count == 0) return @"";
    
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"update %@ set ", tableName];
    NSMutableArray *values = [NSMutableArray array];
    [updateKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sql appendFormat:@"%@=?,", jh_appendPrefix(obj)];
        [values addObject:jh_formatSaveValue([object valueForKey:obj])];
    }];
    
    //删除最后的","
    [sql deleteCharactersInRange:NSMakeRange(sql.length - 1, 1)];
    
    if (where.length) {
        [sql appendFormat:@" where %@;", where];
    }
    
    *toValues = values;
    return sql;
}

- (NSString *)makeCountSQLWithTable:(NSString *)tableName where:(NSString *)where {
    NSMutableString *sql = [[NSMutableString alloc] initWithFormat:@"select count(*) from %@", tableName];
    
    if (where.length) {
        [sql appendFormat:@" where %@", where];
    }
    
    return sql;
}

- (NSString *)makePrimaryKeyWhereSQLWithObj:(id)object {
    NSArray <NSString *>*primaryKeys = [[object class] jh_primaryKeys];
    if (primaryKeys.count == 0) return nil;
    //存在主键
    NSMutableString *whereSQL = [[NSMutableString alloc] init];
    [primaryKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        [whereSQL appendFormat:@"%@=%@ and ", jh_appendPrefix(key), jh_formatWhereValue([object valueForKey:key])];
    }];
    
    [whereSQL deleteCharactersInRange:NSMakeRange(whereSQL.length - 4, 4)];
    return whereSQL;
}


#pragma mark - 懒加载
- (FMDatabaseQueue *)queue {
    if (_queue == nil) {
        _queue = [FMDatabaseQueue databaseQueueWithPath:jh_dbPath(_dbName)];
    }
    return _queue;
}

- (dispatch_semaphore_t)semaphore {
    if (_semaphore == nil) {
        _semaphore = dispatch_semaphore_create(0);
    }
    return _semaphore;
}

@end
