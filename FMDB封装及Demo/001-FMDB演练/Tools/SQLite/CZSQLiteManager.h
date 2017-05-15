//
//  CZSQLiteManager.h
//  001-FMDB演练
//
//  Created by samCydia on 17/3/16.
//  Copyright © 2017年 SAM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface CZSQLiteManager : NSObject

+ (instancetype)sharedManager;

/// 数据库队列
@property (nonatomic, strong, readonly) FMDatabaseQueue *queue;

/// 执行 SQL 返回查询字典数组
- (NSArray *)queryRecordset:(NSString *)sql;

@end
