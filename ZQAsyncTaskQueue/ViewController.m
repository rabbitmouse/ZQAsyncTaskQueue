//
//  ViewController.m
//  ZQAsyncTaskQueue
//
//  Created by 朱志勤 on 2021/3/16.
//

#import "ViewController.h"

#import "TaskClass.h"
#import "ZQAsyncQueueHeader.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TaskClass *task = [TaskClass new];

    [[ZQAsyncQueue queue] addTask:task completed:^(id  _Nonnull response) {
        NSLog(@"单个异步任务执行完毕");
    } failure:^(id  _Nonnull err) {
        NSLog(@"%@", err);
    }];


    NSMutableArray *reqs = [NSMutableArray array];
    for (int i = 0; i < 10; ++i) {
        TaskClass *task = [TaskClass new];
        task.number = i;
        [reqs addObject:task];
    }
    NSLog(@"多个异步任务");
    [[ZQAsyncQueue queue] addBatchTasks:reqs completed:^(id  _Nonnull response) {
        NSLog(@"异步任务 %@", response);
    } failure:^(id  _Nonnull err) {
        NSLog(@"%@", err);
    }];
    
    
    NSMutableArray *reqs1 = [NSMutableArray array];
    for (int i = 0; i < 10; ++i) {
        TaskClass *task = [TaskClass new];
        task.number = i;
        [reqs1 addObject:task];
    }
    NSLog(@"多个异步任务合并 like Promise.all");
    [[ZQAsyncQueue queue] addBatchTasksCombineResult:reqs1 completed:^(id  _Nonnull response) {
        NSLog(@"异步任务合并返回 %@", response);
    } failure:^(id  _Nonnull err) {
        NSLog(@"%@", err);
    }];
}


@end
