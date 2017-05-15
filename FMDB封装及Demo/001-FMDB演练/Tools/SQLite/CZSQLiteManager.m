//
//  CZSQLiteManager.m
//  001-FMDB演练
//
//  Created by samCydia on 17/3/16.
//  Copyright © 2017年 SAM. All rights reserved.
//

#import "CZSQLiteManager.h"

@implementation CZSQLiteManager

+ (instancetype)sharedManager {
    static id instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSString *dbName = @"my.db";
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        NSString *path = [cachePath stringByAppendingPathComponent:dbName];
        
        NSLog(@"%@", path);
        
        // 建立数据库操作队列，如果数据库不存在，会建立数据库
        _queue = [FMDatabaseQueue databaseQueueWithPath:path];
        
        // 创建数据表
        [self createTable];
    }
    return self;
}

#pragma mark - 数据库操作方法
- (NSArray *)queryRecordset:(NSString *)sql {
    
    NSMutableArray *arrayM = [NSMutableArray array];
    
    [_queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *rs = [db executeQuery:sql];
        
        while (rs.next) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            int colCount = rs.columnCount;
            
            for (int col = 0; col < colCount; col++) {

                NSString *name = [rs columnNameForIndex:col];
                id value = [rs objectForColumnName:name];
                
                dict[name] = value;
            }
            
            [arrayM addObject:dict];
        }
    }];
    
    return arrayM.copy;
}

#pragma mark - 创建数据表
- (void)createTable {
    // 1. 准备 SQL
    NSString *path = [[NSBundle mainBundle] pathForResource:@"db.sql" ofType:nil];
    NSString *sql = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    // 2. 执行 SQL
    [_queue inDatabase:^(FMDatabase *db) {
        // [NSThread sleepForTimeInterval:1.0];
        
        // executeStatements 可以一次性执行多条语句，用于创建数据表
        BOOL result = [db executeStatements:sql];
        
        NSLog(@"创建数据表 %@", result ? @"成功" : @"失败");
    }];
    
    NSLog(@"创表完成");
}

@end
