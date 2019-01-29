//
//  BGUserApiManger.m
//  BGNetworkDemo
//
//  Created by Little.Daddly on 2018/6/3.
//  Copyright © 2018年 Little.Daddly. All rights reserved.
//

#import "BGUserApiManger.h"
#import "NSUserDefaults+BGAdd.h"
NSString *_testUrl = nil;
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

- (BOOL)enableHttpsReq{
    return YES;
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
+ (NSString *)reqTaobao:(NSDictionary *)params completionBlock:(BGNetworkCompletionBlcok)completionBlock{
    _testUrl = @"https://www.apiopen.top/journalismApi";
    return [[BGUserApiManger shareManager] dataRequestWithExtraMethod:BGRequestMethodPost url:_testUrl params:nil completionHandle:completionBlock];
}
+ (NSString *)reqHttpsCompletionBlcok:(BGNetworkCompletionBlcok)completionBlock{
    _testUrl = @"https://aikanvod.miguvideo.com/video/p/bitRateAdapt.jsp?vt=9&param=%7b%22CGI%22%3a%22460-00-760095-1%22%7d";
    return [[BGUserApiManger shareManager] dataRequestWithExtraMethod:BGRequestMethodGet url:_testUrl params:nil completionHandle:completionBlock];
}
@end
