//
//  AKHomeApiM.h
//  miguaikan
//
//  Created by Little.Daddly on 2019/3/23.
//  Copyright © 2019 cmvideo. All rights reserved.
//

#import "BGBaseApiManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AKHomeApiM : BGBaseApiManager <BGApiConfigDelegate>
/** 首页频道列表 */
+ (NSString *)reqChannelSequenceParams:(NSDictionary *)params
                 completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;
/** 获取banner列表 */
+ (NSString *)reqI_bannerDataInfoParams:(NSDictionary *)params
                       completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;
/** 运营位 */
+ (NSString *)reqNewHomeBannerParams:(NSDictionary *)params
                        completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;
/** 瀑布流 */
+ (NSString *)reqI_contentList_v1107URL:(NSString *)url
                                 params:(NSDictionary *)params
                  isMandatoryPullRemote:(BOOL)isMandatoryPullRemote
                        completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;
/** 换一批 */
+ (NSString *)reqRefreshVodListURL:(NSString *)url
                   completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;

/** 获取下拉刷新广告 */
+ (NSString *)reqGetDownRefreshURL:(NSDictionary *)params
                   completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;
/** 悬浮球 */
+ (NSString *)reqGetFloatInfoURL:(NSDictionary *)params
                 completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;
/** 悬浮球领取奖励 */
+ (NSString *)reqGetBallPrizeURL:(NSDictionary *)params
                 completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;
/** 重磅推荐 */
+ (NSString *)reqHwRecommendListURL:(NSDictionary *)params
                    completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;
/** 是否为移动网络 */
+ (NSString *)reqISCMCCURLCompletionBlock:(__nullable BGNetworkCompletionBlcok)completionBlcok;


/** 华为瀑布流 重定向 */
+ (NSDictionary *)getContentListParamWithOrigianlURL:(NSString *)url
                                      withOtherParam:(NSDictionary *)otherP;

/** 精选更多 */
+ (NSString *)reqFeaturedMoreURL:(NSString *)url
                          params:(NSDictionary *)params
                 completionBlcok:(__nullable BGNetworkCompletionBlcok)completionBlcok;

@end

NS_ASSUME_NONNULL_END
