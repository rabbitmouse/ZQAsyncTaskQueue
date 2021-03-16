//
//  ZQAsyncQueue.m
//  ZQAsyncTaskQueue
//
//  Created by 朱志勤 on 2021/3/2.
//

#import "ZQAsyncQueue.h"

@interface ZQAsyncQueue()

@property (nonatomic, strong) NSOperationQueue *operationQueue ;

@property (nonatomic, strong) dispatch_queue_t concurrent ;

@end

@implementation ZQAsyncQueue

+ (instancetype)queue {
    static ZQAsyncQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[self class] new];
        
        [queue configOperationQueue];
        queue.concurrent = dispatch_queue_create("task.add.ConcurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    });
    return queue;
}

#pragma mark - publish methods
- (ZQAsyncOperation *)addTask:(id<ZQOperation>)task
      completed:(void(^)(id response))completedBlock
        failure:(void(^)(id err))failureBlock {
    
    ZQAsyncOperation *opt = [ZQAsyncOperation operationWithTask:task finished:^(BOOL isSuccess, id  _Nonnull response) {
        
        // 处理task的回调
        if (isSuccess) {
            !completedBlock ?: completedBlock(response);
        } else {
            !failureBlock ?: failureBlock(response);
        }
        
    } canceled:^{
        !failureBlock ?: failureBlock([self constructCancelError]);
    }];
    
    [self.operationQueue addOperation:opt];
    
    return opt;
}

- (NSArray<ZQAsyncOperation *> *)addBatchTasks:(NSArray<id<ZQOperation>> *)tasks
            completed:(void(^)(id response))completedBlock
              failure:(void(^)(id err))failureBlock {
    
    NSMutableArray<ZQAsyncOperation *> *opts = [NSMutableArray array];
    
    [tasks enumerateObjectsUsingBlock:^(id<ZQOperation>  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
       
        ZQAsyncOperation *opt = [ZQAsyncOperation operationWithTask:task finished:^(BOOL isSuccess, id  _Nonnull response) {
            
            // 处理task的回调
            if (isSuccess) {
                !completedBlock ?: completedBlock(response);
            } else {
                !failureBlock ?: failureBlock(response);
            }
            
        } canceled:^{
            !failureBlock ?: failureBlock([self constructCancelError]);
        }];
        
        [opts addObject:opt];
    }];
    
    [self.operationQueue addOperations:opts waitUntilFinished:NO];
    
    return [opts copy];
}

- (NSArray<ZQAsyncOperation *> *)addBatchTasksCombineResult:(NSArray<id<ZQOperation>> *)tasks
            completed:(void(^)(id response))completedBlock
            failure:(void(^)(id err))failureBlock {
    
    __block BOOL allSuccess = YES;
    __block id error = nil;
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:tasks.count];
    
    NSMutableArray<ZQAsyncOperation *> *opts = [NSMutableArray array];
    
    [tasks enumerateObjectsUsingBlock:^(id<ZQOperation>  _Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
       
        ZQAsyncOperation *opt = [ZQAsyncOperation operationWithTask:task finished:^(BOOL isSuccess, id  _Nonnull response) {
            
            @synchronized (self) {
                // 处理task的回调
                if (isSuccess) {
                    // 成功，保存response到result数组中
                    [results setObject:response atIndexedSubscript:idx];
                } else {
                    // 失败，取消其他任务，抛出异常
                    if (error == nil) {
                        allSuccess = NO;
                        error = response;
                        [self cancelOperations:opts];
                    }
                }
            }
            
        } canceled:^{
            @synchronized (self) {
                // 失败，取消其他任务，抛出异常
                if (error == nil) {
                    allSuccess = NO;
                    error = [self constructCancelError];
                    [self cancelOperations:opts];
                }
            }
        }];
        
        [results addObject:@(0)]; //预填充
        [opts addObject:opt];
    }];
    
    dispatch_async(self.concurrent, ^{
        [self.operationQueue addOperations:opts waitUntilFinished:YES];
        if (allSuccess) {
            !completedBlock ?: completedBlock([results copy]);
        } else {
            !failureBlock ?: failureBlock(error);
        }
    });
    
    return [opts copy];
}

#pragma mark - private methods

- (void)configOperationQueue {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 100;
    
    self.operationQueue = queue;
}

- (NSError *)constructCancelError {
    NSError* cancelError = [NSError errorWithDomain:NSCocoaErrorDomain code:1001 userInfo:@{@"msg": @"任务被取消"}];
    return cancelError;
}

- (void)cancelOperations:(NSArray<ZQAsyncOperation *> *)opts {
    @synchronized (self) {
        for (ZQAsyncOperation *opt in opts) {
            if (!opt.isCancelled) {
                [opt cancel];
            }
        }
    }
}

#pragma mark - getter & setter
- (NSArray<NSOperation *> *)operations {
    return self.operationQueue.operations;
}

@end
