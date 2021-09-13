//
//  SQCRNetProtocol.h
//  SQCombineRequest
//
//  Created by 孙强 on 2021/8/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SQCRNetMethod) {
    SQCRNetMethodGet,
    SQCRNetMethodPost,
    SQCRNetMethodDelete,
    SQCRNetMethodPut,
};

@protocol SQCRNetProtocol <NSObject>

- (NSURLSessionDataTask *)requestWithMethod:(SQCRNetMethod)method
                      url:(NSString *)url
                   header:(NSDictionary *)header
                    param:(NSDictionary *)param
          timeoutInterval:(NSTimeInterval)timeoutInterval
                  success:(void (^)(id _Nullable responseObject))success
                  failure:(void (^)(NSError * _Nonnull error))failure;

@end

NS_ASSUME_NONNULL_END
