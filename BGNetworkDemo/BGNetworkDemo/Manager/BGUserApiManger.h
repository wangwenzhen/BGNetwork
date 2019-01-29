//
//  BGUserApiManger.h
//  BGNetworkDemo
//
//  Created by Little.Daddly on 2018/6/3.
//  Copyright © 2018年 Little.Daddly. All rights reserved.
//

#import "BGBaseApiManager.h"

@interface BGUserApiManger : BGBaseApiManager <BGApiConfigDelegate>
/** 用户注册 */
+ (NSString *)requestUserSignUpParams:(NSDictionary *)params completionBlcok:(BGNetworkCompletionBlcok)completionBlcok;
/** 用户登录 */
+ (NSString *)requestUserLoginParams:(NSDictionary *)params completionBlock:(BGNetworkCompletionBlcok)completionBlock;
/** 用户是否存在 */
+ (NSString *)requestUserIsCreate:(NSDictionary *)params completionBlock:(BGNetworkCompletionBlcok)completionBlock;

/** 一个测试用的 免费开放接口 */
+ (NSString *)reqTaobao:(NSDictionary *)params completionBlock:(BGNetworkCompletionBlcok)completionBlock;
/** 测试强制请求 https */
+ (NSString *)reqHttpsCompletionBlcok:(BGNetworkCompletionBlcok)completionBlock;
@end
