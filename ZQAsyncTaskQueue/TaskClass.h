//
//  TaskClass.h
//  ZQAsyncTaskQueue
//
//  Created by 朱志勤 on 2021/3/16.
//

#import <Foundation/Foundation.h>
#import "ZQAsyncQueueHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskClass : NSObject<ZQOperation>

- (void)asyncPerform;
- (void)cancel;

@property (nonatomic, copy) ZQAsyncOperationFinishBlock finishedBlock;

@property (nonatomic, assign) NSUInteger number;

@end

NS_ASSUME_NONNULL_END
