//
//  ZQAsyncOperation.h
//  ZQAsyncTaskQueue
//
//  Created by 朱志勤 on 2021/3/1.
//

#import <Foundation/Foundation.h>
#import "ZQOperationProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZQTaskFinishedBlock)(BOOL isSuccess ,_Nullable id response);
typedef void(^ZQTaskCancelBlock)(void);

@interface ZQAsyncOperation : NSOperation

+ (instancetype)operationWithTask:(id<ZQOperation>)task
                         finished:(ZQTaskFinishedBlock)finishedBlock
                         canceled:(ZQTaskCancelBlock)cancelBlock;


@property (nonatomic, strong) id<ZQOperation> operationTask;

@end

NS_ASSUME_NONNULL_END
