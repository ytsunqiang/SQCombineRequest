//
//  SQCombineRequest.m
//  SQCombineRequest
//
//  Created by 孙强 on 2021/8/8.
//

#import "SQCombineRequest.h"
#import <os/lock.h>

//#if __has_include("SQCRNetTool.h")
#ifdef SQCOMBINEREQUESTNETTOOL
#import "SQCRNetTool.h"
#endif

#define LOCK os_unfair_lock_lock(&_lock);
#define UNLOCK os_unfair_lock_unlock(&_lock);

typedef void(^SQCRBlock)(SQCombineRequestResult* result);

@implementation SQCombineRequestResult

@end

@interface SQCombineRequest () {
    @public os_unfair_lock _lock;
}

@property (nonatomic, strong) NSMutableArray *requstItems;

@property (nonatomic, assign) NSInteger flag;

@property (nonatomic, assign) BOOL started;

@property (nonatomic, copy) SQCRBlock completeBlock;

@property (nonatomic, strong) NSDictionary *dependData;

@end

@implementation SQCombineRequest
- (void)dealloc {
    NSLog(@"dealloc %@", NSStringFromClass(self.class));
    [self stop];
}
//初始化
- (instancetype)init {
    if (self = [super init]) {
        _lock = OS_UNFAIR_LOCK_INIT;
        self.flag = 0;
    }
    return self;
}

- (NSMutableArray *)requstItems {
    if (!_requstItems) {
        _requstItems = [NSMutableArray arrayWithCapacity:10];
    }
    return _requstItems;
}

- (void)addData:(NSDictionary *)data {
    
    LOCK
    if (data != nil && [data isKindOfClass:NSDictionary.class] && data.count > 0) {
        
        if (self.dependData == nil) {
            self.dependData = @{};
        }
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithDictionary:self.dependData];
        [temp addEntriesFromDictionary:data];
        self.dependData = temp.copy;
    }
    UNLOCK
}

- (void)start {
    
    if (self.started) {
        return;
    }
    
    self.started = YES;
    
    [self startRequest];
}

- (void)stop {
    [self.requstItems makeObjectsPerformSelector:@selector(stop)];
    [self reset];
}

- (void)startRequest {
    NSString *str = [NSString stringWithFormat:@"%@ 需要重写 %@ 方法",NSStringFromClass(self.class), NSStringFromSelector(_cmd)];
    NSAssert(0, str);
}

- (void)success {
    SQCombineRequestResult *result = [[SQCombineRequestResult alloc] init];
    result.stop = NO;
    result.dataToNextRequest = self.dependData;
    [self complete:result];
}

- (void)fail:(NSError *)error {
    SQCombineRequestResult *result = [[SQCombineRequestResult alloc] init];
    result.stop = YES;
    if (error) {
        result.dataToNextRequest = @{@"error": error};
    }
    [self complete:result];
}

- (void)complete:(SQCombineRequestResult *)success {
    if(self.completeBlock) {
        self.completeBlock(success);
    }
    [self reset];
}

- (void)reset {
    self.flag = 0;
    self.started = NO;
    self.completeBlock = nil;
    self.dependData = nil;
}

@end


@implementation SQCombineRequestItem

#ifdef SQCOMBINEREQUESTNETTOOL

- (instancetype)init {
    if (self = [super init]) {
        self.netRequestTool = [[SQCRNetTool alloc] init];
    }
    return self;
}
#endif


- (void)startRequest {
    
    if (self.requestWillStart) {
        self.requestWillStart(self);
    }
    NSDictionary *param = nil;
    if (self.requestParam) {
        param = self.requestParam(self.dependData);
    }
    
    if (self.extensionData) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:self.extensionData];
        [dict addEntriesFromDictionary:param];
        param = dict.copy;
    }
    
    
    if ([self.netRequestTool respondsToSelector:@selector(requestWithMethod:url:header:param:timeoutInterval:success:failure:)]) {
        _task = [self.netRequestTool requestWithMethod:self.method
                                                   url:self.url
                                                header:self.header
                                                 param:param
                                       timeoutInterval:self.timeout
                                               success:^(id  _Nullable responseObject) {
            
            SQCombineRequestResult *result = [[SQCombineRequestResult alloc] init];
            if (self.successBlock) {
                self.successBlock(responseObject, result);
            }
            [self complete:result];
        }
                                               failure:^(NSError *  _Nonnull error) {
            if (self.failBlock && ![error.localizedDescription isEqualToString:@"cancelled"]) {
                self.failBlock(error);
            }
            [self fail: error];
        }];
    } else {
        NSString *str = [NSString stringWithFormat:@"%@ 的 netRequestTool需要自己设置并且实现SQCRNetProtocol协议方法",NSStringFromClass(self.class)];
        NSAssert(0, str);
        NSError *err = [NSError errorWithDomain:str code:-1 userInfo:nil];
        [self fail: err];
    }
}

- (void)stop {
    [self.task cancel];
    [self reset];
}

@end


@implementation SQCombineChainRequest

- (void)startRequest {
    [self startNextRequest];
}

- (void)addRequest:(SQCombineRequest *)request {
    LOCK
    [self.requstItems addObject:request];
    UNLOCK
}

- (void)startNextRequest {
    
    if (self.flag < self.requstItems.count) {
        SQCombineRequest *request = self.requstItems[self.flag];
        request.dependData = self.dependData;
        __weak typeof(self) weakSelf = self;
        request.completeBlock = ^(SQCombineRequestResult *success){
            if (!success.stop) {
                [weakSelf addData: success.dataToNextRequest];
                [weakSelf startNextRequest];
            } else {
                NSError *error = success.dataToNextRequest[@"error"];
                if (weakSelf.failBlock) {
                    weakSelf.failBlock(error);
                }
                [weakSelf fail:error];
            }
        };
        
        [request start];
        self.flag += 1;
    } else {
        if (self.successBlock) {
            SQCombineRequestResult *result = [[SQCombineRequestResult alloc] init];
            self.successBlock(nil, result);
            [self addData:result.dataToNextRequest];
            result.dataToNextRequest = self.dependData;
            [self complete:result];
        } else {
            [self success];
        }
    }
    
}

@end

@implementation SQCombineBatchRequest

- (void)addRequests:(NSArray<SQCombineRequest *> *)requests {
    LOCK
    self.requstItems = requests.copy;
    UNLOCK
}

- (void)startRequest {

    LOCK
    NSArray *items = self.requstItems.copy;
    UNLOCK
    for (SQCombineRequest *item in items) {
        item.dependData = self.dependData;
        [item start];
        __weak typeof(self) weakSelf = self;
        item.completeBlock = ^(SQCombineRequestResult *success){
            if (!success.stop) {
                weakSelf.flag += 1;
                [self addData:success.dataToNextRequest];
                if (weakSelf.flag == items.count) {
                    if (weakSelf.successBlock) {
                        SQCombineRequestResult *result = [[SQCombineRequestResult alloc] init];
                        weakSelf.successBlock(nil, result);
                        [weakSelf addData:result.dataToNextRequest];
                        result.dataToNextRequest = weakSelf.dependData;
                        [weakSelf complete:result];
                    } else {
                        [weakSelf success];
                    }
                }
            } else {
                NSError *error = success.dataToNextRequest[@"error"];
                if (weakSelf.failBlock) {
                    weakSelf.failBlock(error);
                }
                [weakSelf fail:error];
                [weakSelf stop];
            }
        };
    }
    
}


@end
