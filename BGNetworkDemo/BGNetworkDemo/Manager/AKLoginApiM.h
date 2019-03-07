//
//  AKLoginApiM.h
//  miguaikan
//
//  Created by Little.Daddly on 2019/3/7.
//  Copyright © 2019 cmvideo. All rights reserved.
//

#import "BGBaseApiManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AKLoginApiM : BGBaseApiManager <BGApiConfigDelegate>
/** 获取login edg地址  */
+ (NSString *)requestLoginParams:(NSDictionary *)params
                 completionBlcok:(BGNetworkCompletionBlcok)completionBlcok
                redirectionBlock:(BGNetworkCompletionBlcok)redirectionBlock;
@end

NS_ASSUME_NONNULL_END
