//
//  SQCRNetTool.m
//  SQCombineRequest
//
//  Created by 孙强 on 2021/8/8.
//

#import "SQCRNetTool.h"
#import "AFNetworking.h"

@implementation SQCRNetTool

- (NSURLSessionDataTask *)requestWithMethod:(SQCRNetMethod)method
                                        url:(NSString *)url
                                     header:(NSMutableDictionary *)header
                                      param:(NSDictionary *)param
                            timeoutInterval:(NSTimeInterval)timeoutInterval
                                    success:(void (^)(id _Nullable responseObject))success
                                    failure:(void (^)(NSError *_Nonnull error))failure {
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if (timeoutInterval) {
        manager.requestSerializer.timeoutInterval = timeoutInterval;
    }
    ((AFJSONResponseSerializer*)manager.responseSerializer).removesKeysWithNullValues=YES;
    NSURLSessionDataTask *task;
    switch (method) {
        case SQCRNetMethodPost:
        {
            task = [manager POST:url parameters:param headers:header progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
            break;
        }
            
        case SQCRNetMethodDelete:
        {
            task = [manager DELETE:url parameters:param headers:header success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
                [manager.session finishTasksAndInvalidate];
            }];
            break;
        }
        case SQCRNetMethodPut:
        {
            task = [manager PUT:url parameters:param headers:header success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
            break;
        }
        default:
        {
            task = [manager GET:url parameters:param headers:header progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                if (success) {
                    success(responseObject);
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                if (failure) {
                    failure(error);
                }
            }];
        }
            break;
    }
    return task;
}

@end
