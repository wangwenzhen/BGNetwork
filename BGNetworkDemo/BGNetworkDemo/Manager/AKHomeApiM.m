//
//  AKHomeApiM.m
//  miguaikan
//
//  Created by Little.Daddly on 2019/3/23.
//  Copyright © 2019 cmvideo. All rights reserved.
//

#import "AKHomeApiM.h"

//#import "AKUserM.h"
//#import "UIDevice+AKAdd.h"
@interface AKHomeApiM ()
/** 当前接口 */
@property (nonatomic,copy) NSString *current_url;
@property (nonatomic,strong) NSDictionary *params;
@property (nonatomic,assign) BOOL *noDealCache;//无需特殊处理
@end

@implementation AKHomeApiM
#if  _iscompile
- (BGRequestMethod)defaultRequestMethod{
    return BGRequestMethodGet;
}
- (NSString *)serverDomainPath{
    if ([self.current_url isWD_Req]) { //网达网络请求
        
        BGServerDomainPathType environment = BGAPIEnvironment();
        switch (environment) {
            case BGServerDomainPathTypeRelease: return WDReq_Release;
            case BGServerDomainPathTypeGray: return WDReq_Gray;
            case BGServerDomainPathTypeTest: return WDReq_Debug;
        }
        
    } else {
        return HWReq_PBS;
    }
    
}

- (BTResponseSerializerType)responseSerializerType{
    return BTResponseSerializerTypeJSON;
}
- (NSTimeInterval)requestTimeoutInterval{
    if ([_current_url ex_isEqual:AKChannelSequence_URL]) {
        return 9.;
    }
    return 8.;
}
- (BTRequestSerializerType)requestSerializerType {
    return BTRequestSerializerTypeHTTP;
}

- (NSDictionary *)requestHeaderFieldDictionary{
    return @{
             @"Location": [AKUserM shareManager].epg,
             @"EpgSession": F(@"JSESSIONID=%@",[AKUserM shareManager].reqSessionId),
             };
}

/** 设置单接口的缓存时长 */
- (NSInteger)cacheDataTime{
    if ([_current_url containsString:AKI_contentList_v1107_URL] ||
        [_current_url containsString:@"contentList_v106"] ||
        [_current_url containsString:@"contentList_v204"]) {
        return 30 * 60;//半小时
    } else if([_current_url ex_isEqual:AKChannelSequence_URL]){
        return 30 * 60;//半小时
    }
    return 0;
}




/** 是否开启接口缓存*/
- (BOOL)isEnableCache{
    if (_noDealCache) {
        return NO;
    } else if ([_current_url containsString:AKI_contentList_v1107_URL] ||
        [_current_url containsString:@"contentList_v106"] ||
        [_current_url containsString:@"contentList_v204"]) {
        if (self.isMandatoryPullRemote) {
            return NO;
        }
        
        return YES;
    } else if ([_current_url ex_isEqual:AKChannelSequence_URL]) {
        return YES;
    }
    
    return NO;
}
/** 接口数据缓存的主键 */
- (NSString *)cacheDBId{
    
    if ([_current_url containsString:AKI_contentList_v1107_URL] ||
        [_current_url containsString:@"contentList_v106"] ||
        [_current_url containsString:@"contentList_v204"]) {
        
        NSString *DBId = _params[@"nodeId"];
        return F(@"homeFall_%@",DBId);
    } else if ([_current_url isEqualToString:AKChannelSequence_URL]){
        return @"ChannelSequence_URL";
    }
    
    return @"";
}


/** 是否支持请求失败重试 */
- (BOOL)needRetryReq{
    if ([_current_url ex_isEqual:AKChannelSequence_URL]) {
        return YES;
    }else {
        return NO;
    }
}
/** 最多重试请求次数,未实现默认3 */
- (int)maxRetryReqTimes{
    return 3;
}
/** 请求重试间隔 */
- (int)retryReqInterval{
    return 2;
}
/** 判断请求是否满足业务需求 不满足则请求重试，且不缓存数据, 不实现默认满足 */
- (BOOL)areBusinessNeedMeetWithResponseObject:(id )responseObject{
    if ([_current_url ex_isEqual:AKChannelSequence_URL]) {
        if (responseObject && responseObject[@"channelList"]) {
            return YES;
        } else {
            return NO;
        }
    } else if ([_current_url containsString:AKI_contentList_v1107_URL] ||
               [_current_url containsString:@"contentList_v106"] ||
               [_current_url containsString:@"contentList_v204"]){
        if (responseObject &&
            (responseObject[@"info"] ||
            responseObject[@"subNodes"])) {
                
            return YES;
        } else {
            return NO;
        }
        
    }
    
    

    return YES;
}



#pragma mark - Req
+ (NSString *)reqChannelSequenceParams:(NSDictionary *)params
                       completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok{
    AKHomeApiM *m = [AKHomeApiM new];
    m.current_url = AKChannelSequence_URL;
    return [m dataRequestWithExtraMethod:BGRequestMethodGet
                                     url:AKChannelSequence_URL
                                  params:params
                        completionHandle:completionBlcok];
}

+ (NSString *)reqI_bannerDataInfoParams:(NSDictionary *)params
                        completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok{
    AKHomeApiM *m = [AKHomeApiM new];
    m.current_url = AKI_bannerDataInfo_URL;
    return [m dataRequestWithExtraMethod:BGRequestMethodGet
                                     url:AKI_bannerDataInfo_URL
                                  params:params
                        completionHandle:completionBlcok];
}

+ (NSString *)reqNewHomeBannerParams:(NSDictionary *)params
                     completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok{
    AKHomeApiM *m = [AKHomeApiM new];
    m.current_url = AKNewHomeBanner_URL;
    return [m dataRequestWithExtraMethod:BGRequestMethodGet
                                     url:AKNewHomeBanner_URL
                                  params:params
                        completionHandle:completionBlcok];
}

+ (NSString *)reqI_contentList_v1107URL:(NSString *)url
                                 params:(NSDictionary *)params
                            isMandatoryPullRemote:(BOOL)isMandatoryPullRemote
                           completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok{
    AKHomeApiM *m = [AKHomeApiM new];
    //            cl[i].channelUrl = string.gsub(cl[i].channelUrl, 'contentList_v106', 'i_contentList_v1107')-----------------------只有“contentList_v106”才替换为“i_contentList_v1107”；“/contentList_v204.jsp”保持原样
    m.isMandatoryPullRemote = isMandatoryPullRemote;
    m.params = params;
    if ([url containsString:@"contentList_v106"]) {
        m.current_url = AKI_contentList_v1107_URL;
        
        return [m dataRequestWithExtraMethod:BGRequestMethodPost
                                         url:AKI_contentList_v1107_URL
                                      params:params
                            completionHandle:completionBlcok];
    } else {//不替换 url
        m.current_url = url;
        return [m dataRequestWithExtraMethod:[url isWD_Req] ? BGRequestMethodGet : BGRequestMethodPost
                                         url:url
                                      params:params
                            completionHandle:completionBlcok];
    }
}

+ (NSString *)reqRefreshVodListURL:(NSString *)url
                   completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok{
    AKHomeApiM *m = [AKHomeApiM new];
    return [m dataRequestWithExtraMethod:BGRequestMethodGet
                                     url:url
                                  params:@{@"vt":@(9)}
                        completionHandle:completionBlcok];
}

+ (NSString *)reqGetDownRefreshURL:(NSDictionary *)params
                   completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok{
    AKHomeApiM *m = [AKHomeApiM new];
    m.current_url = AKGetDownRefresh_URL;
    return [m dataRequestWithExtraMethod:BGRequestMethodPost
                                     url:AKGetDownRefresh_URL
                                  params:params
                        completionHandle:completionBlcok];
}

+ (NSString *)reqISCMCCURLCompletionBlock:(__nullable BGNetworkCompletionBlcok)completionBlcok{
    AKHomeApiM *m = [AKHomeApiM new];
    m.current_url = AKCMCC_URL;
    return [m dataRequestWithExtraMethod:BGRequestMethodGet
                                     url:AKCMCC_URL
                                  params:@{@"vt":@(9)}
                        completionHandle:completionBlcok];
}

+ (NSString *)reqGetFloatInfoURL:(NSDictionary *)params
                 completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok {
    AKHomeApiM *m = [AKHomeApiM new];
    m.current_url = AKGetFloatInfo_URL;
    return [m dataRequestWithExtraMethod:BGRequestMethodPost
                                     url:AKGetFloatInfo_URL
                                  params:params
                        completionHandle:completionBlcok];
}
+ (NSString *)reqGetBallPrizeURL:(NSDictionary *)params
                 completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok {
    AKHomeApiM *m = [AKHomeApiM new];
    m.current_url = AKGetBallPrize_URL;
    return [m dataRequestWithExtraMethod:BGRequestMethodGet
                                     url:AKGetBallPrize_URL
                                  params:params
                        completionHandle:completionBlcok];
}
+ (NSString *)reqHwRecommendListURL:(NSDictionary *)params
                    completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok {
    AKHomeApiM *m = [AKHomeApiM new];
    m.current_url = AKHwRecommendList_URL;
    return [m dataRequestWithExtraMethod:BGRequestMethodGet
                                     url:AKHwRecommendList_URL
                                  params:params
                        completionHandle:completionBlcok];
}
+ (NSString *)reqFeaturedMoreURL:(NSString *)url
                          params:(NSDictionary *)params
                 completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok {
    AKHomeApiM *m = [AKHomeApiM new];
    m.current_url = url;
    m.noDealCache = YES;
    return [m dataRequestWithExtraMethod:BGRequestMethodGet
                                     url:url
                                  params:params
                        completionHandle:completionBlcok];
}
+ (NSDictionary *)getContentListParamWithOrigianlURL:(NSString *)url
                                      withOtherParam:(NSDictionary *)otherP{
    if (!url) {
        return nil;
    }
    //"http://wdclt.zj.chinamobile.com/clt/clt/videoList.msp?c=70022194",
      NSArray *url_data = [url componentsSeparatedByString:@"?"];
      NSString *res_url = url_data.lastObject;//nodeId=2000000012
      NSArray *p1_arr = [res_url componentsSeparatedByString:@"="];
    
      NSMutableDictionary *m_dic = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                 p1_arr[0] : p1_arr[1]
                                                                                 }];
    
      [m_dic addEntriesFromDictionary:otherP];
      return m_dic.copy;

}
#endif
@end
