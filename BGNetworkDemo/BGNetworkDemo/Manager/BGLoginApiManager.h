//
//  BGLoginApiManager.h
//  BGNetworkDemo
//
//  Created by Little.Daddly on 2019/3/7.
//  Copyright © 2019 Little.Daddly. All rights reserved.
//

#import "BGBaseApiManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGLoginApiManager : BGBaseApiManager <BGApiConfigDelegate>
+ (NSString *)requestLoginParams:(NSDictionary *)params completionBlcok:(BGNetworkCompletionBlcok)completionBlcok;
@end

NS_ASSUME_NONNULL_END
