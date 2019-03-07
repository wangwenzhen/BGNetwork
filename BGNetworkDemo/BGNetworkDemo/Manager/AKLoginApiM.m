//
//  AKLoginApiM.m
//  miguaikan
//
//  Created by Little.Daddly on 2019/3/7.
//  Copyright © 2019 cmvideo. All rights reserved.
//

#import "AKLoginApiM.h"
#import "AKReqUrl.h"
@interface AKLoginApiM ()
@property (nonatomic,strong) NSMutableDictionary *reqBlockTable;
@end
@implementation AKLoginApiM
- (BTResponseSerializerType)responseSerializerType{
    return BTResponseSerializerTypeJSON;
}

- (BTRequestSerializerType)requestSerializerType {
    return BTRequestSerializerTypeJSON;
}

- (BOOL)enableRedirection{
    return YES;
}
- (void)redirectionUrl:(NSURL *)redirectionUrl originParam:(id)param originReqUrl:(NSString *)originReqUrl{
    NSString *rUrl = redirectionUrl.absoluteString;
    for (NSString *kUrl in self.reqBlockTable) {
        if ([originReqUrl isEqualToString:kUrl]) {
           BGNetworkCompletionBlcok b = self.reqBlockTable[kUrl];
            b(@"test----",nil);
//            [AKLoginApiM reqRedirectionLoginUrl:rUrl Params:param completionBlcok:b];
        }
    }
    NSLog(@"... %@-- %@",redirectionUrl.absoluteString,param);
}
- (BGRequestMethod)defaultRequestMethod{
    return BGRequestMethodGet;
}

- (NSString *)serverDomainPath{
    return HWReq_EDSUrl;
}

+ (NSString *)requestLoginParams:(NSDictionary *)params
                 completionBlcok:(BGNetworkCompletionBlcok)completionBlcok
                redirectionBlock:(BGNetworkCompletionBlcok)redirectionBlock{
    AKLoginApiM *m = [AKLoginApiM shareManager];
    [m.reqBlockTable setValue:redirectionBlock forKey:AKLogin_URL];
    
    return [[AKLoginApiM shareManager] dataRequestWithExtraMethod:BGRequestMethodPost
                                                                    url:AKLogin_URL
                                                                 params:params
                                                       completionHandle:completionBlcok];
}
/** login重定向 */
+ (NSString *)reqRedirectionLoginUrl:(NSString *)url
                              Params:(NSDictionary *)params
                        completionBlcok:(BGNetworkCompletionBlcok)completionBlcok{
    
    return [[AKLoginApiM shareManager] dataRequestWithExtraMethod:BGRequestMethodPost
                                                              url:url
                                                           params:params
                                                 completionHandle:completionBlcok];
}

- (NSMutableDictionary *)reqBlockTable{
    if (!_reqBlockTable) {
        _reqBlockTable = [NSMutableDictionary dictionary];
    }
    return _reqBlockTable;
}
@end
