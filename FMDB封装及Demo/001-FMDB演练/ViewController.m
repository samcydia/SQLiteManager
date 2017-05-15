//
//  ViewController.m
//  001-FMDB演练
//
//  Created by samCydia on 17/3/16.
//  Copyright © 2017年 SAM. All rights reserved.
//

#import "ViewController.h"
#import "CZSQLiteManager.h"

@interface ViewController ()

@end

@implementation ViewController {
    CZSQLiteManager *_manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _manager = [CZSQLiteManager sharedManager];
    
    // [self insertDemo1:@"张三"];
    // SQL 注入演示
    // [self insertDemo3:@"zhang', 0, 0); DELETE FROM T_Person; --"];
    // [self updateDemo:@"隔壁老王"];
    [self manyPersons];
    
}

#pragma mark - 事务处理
- (void)manyPersons {
 
    NSString *sql = @"INSERT INTO T_Person (name, age, height) VALUES (?, ?, ?);";
    
    NSTimeInterval start = CACurrentMediaTime();
    
    NSLog(@"start");
    [_manager.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        for (NSInteger i = 0; i < 10000; i++) {
            if (![db executeUpdate:sql, [@"zhangsan" stringByAppendingFormat:@"%zd", i], @18, @1.4]) {
                *rollback = YES;
            }
            
            // 模拟操作失败，使用 fmdb 不需要 break;
            if (i == 1000) {
                *rollback = YES;
            }
        }
    }];
    
    NSLog(@"%f", CACurrentMediaTime() - start);
}

/// 错误的写法，要把循环放在事务 block 中
- (void)manyPersons2 {
    
    NSString *sql = @"INSERT INTO T_Person (name, age, height) VALUES (?, ?, ?);";
    
    NSTimeInterval start = CACurrentMediaTime();
    
    NSLog(@"start");
        
    for (NSInteger i = 0; i < 10000; i++) {
        
        [_manager.queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            if (![db executeUpdate:sql, [@"zhangsan" stringByAppendingFormat:@"%zd", i], @18, @1.4]) {
                *rollback = YES;
            }
        }];
    }
    
    NSLog(@"%f", CACurrentMediaTime() - start);
}

#pragma mark - 数据库查询
- (void)selectDemo3 {
    NSString *sql = @"SELECT id, name, age, height FROM T_Person;";
    
    NSLog(@"%@", [_manager queryRecordset:sql]);
    
}

- (void)selectDemo2 {
    
    NSString *sql = @"SELECT id, name, age, height FROM T_Person;";
    
    [_manager.queue inDatabase:^(FMDatabase *db) {
       
        // 1. 执行 SQL 返回结果集
        FMResultSet *rs = [db executeQuery:sql];
        
        // 2. 遍历结果集
        NSMutableArray *arrayM = [NSMutableArray array];
        
        while (rs.next) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            // 3. 获取列数
            int colCount = rs.columnCount;
            
            // 4. 遍历每一列
            for (int col = 0; col < colCount; col++) {
                // 5. 获取对象
                NSString *name = [rs columnNameForIndex:col];
                
                id value = [rs objectForColumnName:name];
                
                // 6. 设置字典
                dict[name] = value;
            }
            
            // 7. 添加到数组
            [arrayM addObject:dict];
        }
        
        NSLog(@"%@", arrayM);
    }];
}

- (void)selectDemo1 {
    
    NSString *sql = @"SELECT id, name, age, height FROM T_Person;";
    
    [_manager.queue inDatabase:^(FMDatabase *db) {
        
        // 1. 执行 SQL 返回结果集
        FMResultSet *rs = [db executeQuery:sql];
        
        // 2. 遍历结果集
        NSMutableArray *arrayM = [NSMutableArray array];
        
        while (rs.next) {
        
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            
            dict[@"id"] = @([rs intForColumn:@"id"]);
            dict[@"name"] = [rs stringForColumn:@"name"];
            dict[@"age"] = @([rs intForColumn:@"age"]);
            dict[@"height"] = @([rs doubleForColumn:@"height"]);
            
            [arrayM addObject:dict];
        }
        NSLog(@"%@", arrayM);
    }];
}

#pragma mark - 数据库操作
- (void)deleteDemo {
    NSString *sql = @"DELETE FROM T_Person WHERE id = ?;";
    
    [_manager.queue inDatabase:^(FMDatabase *db) {
        BOOL result = ([db executeUpdate:sql, @6]);
        
        NSLog(@"删除 %@，删除了 %d 行数据", result ? @"成功" : @"失败", db.changes);
    }];
}

- (void)updateDemo:(NSString *)name {

    NSString *sql = @"UPDATE T_Person set name = ? WHERE id = ?;";
    
    [_manager.queue inDatabase:^(FMDatabase *db) {
        BOOL result = ([db executeUpdate:sql, name, @60]);
        
        NSLog(@"更新 %@，修改了 %d 行数据", result ? @"成功" : @"失败", db.changes);
    }];
}

/// 利用预编译指令插入数据
- (void)insertDemo3:(NSString *)name {
    
    NSString *sql = @"INSERT INTO T_Person (name, age, height) VALUES (?, ?, ?);";
    
    [_manager.queue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:sql, name, @19, @1.6];
        
        NSLog(@"插入 %@, id 为 %zd", result ? @"成功" : @"失败", db.lastInsertRowId);
    }];
}

/// 执行单条 SQL
- (void)insertDemo2:(NSString *)name {
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO T_Person (name, age, height) VALUES ('%@', %zd, %f);", name, 18, 1.6];
    NSLog(@"%@", sql);
    
    [_manager.queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:sql];
    }];
}

/// 执行多条 SQL，风险性很大
- (void)insertDemo1:(NSString *)name {
    
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO T_Person (name, age, height) VALUES ('%@', %zd, %f);", name, 18, 1.6];
    NSLog(@"%@", sql);
    
    [_manager.queue inDatabase:^(FMDatabase *db) {
        [db executeStatements:sql];
    }];
}

@end
