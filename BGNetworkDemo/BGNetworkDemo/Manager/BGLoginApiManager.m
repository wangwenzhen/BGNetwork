//
//  BGLoginApiManager.m
//  BGNetworkDemo
//
//  Created by Little.Daddly on 2019/3/7.
//  Copyright © 2019 Little.Daddly. All rights reserved.
//

#import "BGLoginApiManager.h"

@implementation BGLoginApiManager
- (BTResponseSerializerType)responseSerializerType{
    return BTResponseSerializerTypeJSON;
}

- (BTRequestSerializerType)requestSerializerType {
    return BTRequestSerializerTypeJSON;
}

- (BOOL)enableRedirection{
    return YES;
}
- (void)redirectionUrl:(NSURL *)url{
    NSLog(@"... %@",url.absoluteString);
}

- (BGRequestMethod)defaultRequestMethod{
    return BGRequestMethodGet;
}

- (NSString *)serverDomainPath{
    return @"http://aikanlive.miguvideo.com:8082";
}

+ (NSString *)requestLoginParams:(NSDictionary *)params completionBlcok:(BGNetworkCompletionBlcok)completionBlcok{
    
    return [[BGLoginApiManager shareManager] dataRequestWithExtraMethod:BGRequestMethodPost
                                                                  url:@"/EDS/JSON/Login"
                                                               params:params
                                                     completionHandle:completionBlcok];
}
@end
