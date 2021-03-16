//
//  ZQAsyncQueue.h
//  ZQAsyncTaskQueue
//
//  Created by 朱志勤 on 2021/3/2.
//

#import <Foundation/Foundation.h>
#import "ZQAsyncOperation.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZQAsyncQueue : NSObject

+ (instancetype)queue;

/**
 * 添加单个异步任务
 */
- (ZQAsyncOperation *)addTask:(id<ZQOperation>)task
      completed:(void(^)(id response))completedBlock
        failure:(void(^)(id err))failureBlock;

/**
 * 添加一批异步任务
 * 每个任务完成或失败都会回调
 */
- (NSArray<ZQAsyncOperation *> *)addBatchTasks:(NSArray<id<ZQOperation>> *)tasks
            completed:(void(^)(id response))completedBlock
              failure:(void(^)(id err))failureBlock;

/**
 * 添加一批异步任务
 * 所有任务执行完毕才回调，统一在某一条子线程回调
 * 一个失败全部失败
 */
- (NSArray<ZQAsyncOperation *> *)addBatchTasksCombineResult:(NSArray<id<ZQOperation>> *)tasks
            completed:(void(^)(id response))completedBlock
              failure:(void(^)(id err))failureBlock;

@property (nonatomic, strong, readonly) NSArray<NSOperation *> *operations ;

@end

NS_ASSUME_NONNULL_END
