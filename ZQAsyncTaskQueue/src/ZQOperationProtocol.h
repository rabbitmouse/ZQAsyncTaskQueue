//
//  ZQOperationProtocol.h
//  ZQAsyncTaskQueue
//
//  Created by 朱志勤 on 2021/3/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZQAsyncOperationFinishBlock)(BOOL isSuccess ,_Nullable id response);

@protocol ZQOperation <NSObject>

@required
- (void)asyncPerform;
- (void)cancel;

@property (nonatomic, copy) ZQAsyncOperationFinishBlock finishedBlock;

@end

NS_ASSUME_NONNULL_END
