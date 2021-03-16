//
//  TaskClass.m
//  ZQAsyncTaskQueue
//
//  Created by 朱志勤 on 2021/3/16.
//

#import "TaskClass.h"

@implementation TaskClass

// 手动指定属性自动合成
@synthesize finishedBlock;

- (void)asyncPerform {
    // 模拟异步任务
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 模拟异步回调
            // 调用finishedBlock，告诉任务队列此任务已完成
            NSString *response = [NSString stringWithFormat:@"number is %ld", self.number];
            !self.finishedBlock ?: self.finishedBlock(YES, response);
        });
    });
}

- (void)cancel {
    // 取消执行的异步任务
}

@end
