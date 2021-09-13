//
//  SQCombineRequest.h
//  SQCombineRequest
//
//  Created by 孙强 on 2021/8/8.
//

#import <Foundation/Foundation.h>
#import "SQCRNetProtocol.h"
//! Project version number for SQCombineRequest.
FOUNDATION_EXPORT double SQCombineRequestVersionNumber;

//! Project version string for SQCombineRequest.
FOUNDATION_EXPORT const unsigned char SQCombineRequestVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <SQCombineRequest/PublicHeader.h>
@interface SQCombineRequestResult : NSObject
///如果本次数据不正确,要终止网络请求链,stop传YES
@property (nonatomic, assign) BOOL stop;
///要传递给下一个网络请求的数据
@property (nonatomic, strong) NSDictionary *dataToNextRequest;

@end
@interface SQCombineRequest : NSObject
///成功回调 data为网络数据,result决定网络下一个网络请求是否继续,以及传递给下一个网络请求的数据
@property (nonatomic, copy) void(^successBlock)(id data, SQCombineRequestResult *result);
///失败回调
@property (nonatomic, copy) void(^failBlock)(id error);

- (void)start;

- (void)stop;

@end


@interface SQCombineRequestItem : SQCombineRequest
#pragma mark --- 网络工具
///可设置自己的网络请求工具
@property (nonatomic, strong) id<SQCRNetProtocol> netRequestTool;
///请求的task
@property (nonatomic, strong, readonly) NSURLSessionDataTask *task;

#pragma mark --- 网络参数
///请求方式
@property (nonatomic, assign) SQCRNetMethod method;
///请求的url
@property (nonatomic, copy) NSString *url;
///通过这个block返回网络请求的参数,其中dependParam是前面所有网络传递过来的参数
@property (nonatomic, copy) NSDictionary *(^requestParam)(NSDictionary *dependParam);
///这个是设置一些默认参数,网络请求时会组合extensionData跟上面block获取的参数
@property (nonatomic, copy) NSDictionary *extensionData;
///网络请求header
@property (nonatomic, copy) NSDictionary *header;
///超时时间
@property (nonatomic, assign) NSTimeInterval timeout;


#pragma mark --- 回调
///网络请求将要开始
@property (nonatomic, copy) void(^requestWillStart)(SQCombineRequestItem *requestItem);

@end
///多个网络请求按照顺序执行
@interface SQCombineChainRequest : SQCombineRequest

- (void)addRequest:(SQCombineRequest *)request;

@end
///多个网络请求同时请求
@interface SQCombineBatchRequest : SQCombineRequest

///仅在start之前添加有效
- (void)addRequests:(NSArray<SQCombineRequest *> *)requests;

@end

