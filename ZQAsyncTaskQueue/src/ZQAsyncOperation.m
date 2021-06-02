//
//  ZQAsyncOperation.m
//  ZQAsyncTaskQueue
//
//  Created by 朱志勤 on 2021/3/1.
//

#import "ZQAsyncOperation.h"

@interface ZQAsyncOperation()

//是否正在执行
@property (assign, nonatomic, getter=isExecuting) BOOL executing;
//是否已经完成
@property (assign, nonatomic, getter=isFinished) BOOL finished;

@property (nonatomic, copy) ZQTaskFinishedBlock finishedBlock;
@property (nonatomic, copy) ZQTaskCancelBlock cancelBlock;

//线程对象
@property (strong, atomic) NSThread *thread;

@end

@implementation ZQAsyncOperation

@synthesize executing = _executing;
@synthesize finished = _finished;

#pragma mark - life cycle

- (void)dealloc {
    NSLog(@"operation对象释放了");
}

+ (instancetype)operationWithTask:(id<ZQOperation>)task
                         finished:(ZQTaskFinishedBlock)finishedBlock
                         canceled:(ZQTaskCancelBlock)cancelBlock {
    
    return [[self alloc] initWithOperationTask:task finished:finishedBlock canceled:cancelBlock];
}

- (instancetype)initWithOperationTask:(id<ZQOperation>)task
                   finished:(ZQTaskFinishedBlock)finishedBlock
                   canceled:(ZQTaskCancelBlock)cancelBlock {
    self = [super init];
    if (self) {
        _operationTask = task;
        _finishedBlock = [finishedBlock copy];
        _cancelBlock = [cancelBlock copy];
        _executing = NO;
        _finished = NO;
        
    }
    return self;
}


#pragma mark - override func

- (void)start {
    @synchronized (self) {
        // 如果当前任务被取消，标记结束，并清理
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        
        // 执行异步任务
        if (self.operationTask) {
            __weak __typeof__(self) wself = self;
            self.operationTask.finishedBlock = ^(BOOL isSuccess, id  _Nonnull response) {
                // 完成回调
                __strong __typeof(wself) sself = wself;
                !sself.finishedBlock ?: sself.finishedBlock(isSuccess, response);
                
                // 完毕
                [sself done];
            };
            [self.operationTask asyncPerform];
        }
    }
}

- (void)cancel {
    @synchronized (self) {
        if (self.thread) {
            [self performSelector:@selector(cancelTask) onThread:self.thread withObject:nil waitUntilDone:NO];
        } else {
            [self cancelTask];
        }
    }
}

#pragma mark - private func

- (void)cancelTask {
    if (self.isFinished) {
        return;
    }
    [super cancel];
    // 调用cancel回调
    !self.cancelBlock ?: self.cancelBlock();
    
    // 告诉任务对象取消操作
    if (self.operationTask) {
        [self.operationTask cancel];
    }
    // 完成该任务
    [self done];
}


//任务执行完毕之后，修改当前任务的结束状态（YES）和执行状态（NO），执行清理操作
- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

//清理操作
- (void)reset {
    self.cancelBlock = nil;
    self.finishedBlock = nil;
    self.thread = nil;
}

#pragma mark - getter && setter


- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isAsynchronous {
    return YES;
}

@end
