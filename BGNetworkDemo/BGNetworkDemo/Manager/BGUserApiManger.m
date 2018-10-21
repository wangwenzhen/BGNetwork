//
//  BGUserApiManger.m
//  BGNetworkDemo
//
//  Created by Little.Daddly on 2018/6/3.
//  Copyright © 2018年 Little.Daddly. All rights reserved.
//

#import "BGUserApiManger.h"
#import "NSUserDefaults+BGAdd.h"
@interface BGBaseApiManager ()
@end
@implementation BGUserApiManger

- (BTResponseSerializerType)responseSerializerType{
    return BTResponseSerializerTypeJSON;
}

- (BTRequestSerializerType)requestSerializerType {
    return BTRequestSerializerTypeHTTP;
}

- (BGRequestMethod)defaultRequestMethod{
    return BGRequestMethodGet;
}

- (NSString *)serverDomainPath{
    BGServerDomainPathType serverDomainPathType = BGAPIEnvironment();
    switch (serverDomainPathType) {
        case BGServerDomainPathTypeTest:return BG_Test;
        case BGServerDomainPathTypeRelease:return BG_Release;
        default:return nil;
    }
}

+ (NSString *)requestUserSignUpParams:(NSDictionary *)params completionBlcok:(BGNetworkCompletionBlcok)completionBlcok{

    return [[BGUserApiManger shareManager] dataRequestWithExtraMethod:BGRequestMethodPost
                                                                  url:User_SignUp_URL
                                                               params:params
                                                     completionHandle:completionBlcok];
}

+ (NSString *)requestUserLoginParams:(NSDictionary *)params completionBlock:(BGNetworkCompletionBlcok)completionBlock{
    return [[BGUserApiManger shareManager] dataRequestWithExtraMethod:BGRequestMethodGet url:Login_URL params:params completionHandle:completionBlock];
}

+ (NSString *)requestUserIsCreate:(NSDictionary *)params completionBlock:(BGNetworkCompletionBlcok)completionBlock{
    return [[BGUserApiManger shareManager] dataRequestWithExtraMethod:BGRequestMethodPost url:User_Is_Registered params:params completionHandle:completionBlock];
}
@end
