//
//  BGNetworkManager.m
//  BGNetworkDemo
//
//  Created by Little.Daddly on 2018/6/3.
//  Copyright © 2018年 Little.Daddly. All rights reserved.
//

#import "BGNetworkManager.h"
#import "BGBaseApiManager.h"

@interface BGHTTPSessionManager : AFHTTPSessionManager
- (instancetype)initWithApiManager:(BGBaseApiManager *)apiManager;

@end
@implementation BGHTTPSessionManager
- (instancetype)initWithApiManager:(BGBaseApiManager *)apiManager{
    if (self = [super init]) {
        self =(BGHTTPSessionManager *)[AFHTTPSessionManager manager];
        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(enableHttpsReq)]) {
            if (apiManager.apiConfigDelegate.enableHttpsReq) {
                //忽略https的证书问题 强制打开
                AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
                [securityPolicy setValidatesDomainName:NO];
                self.securityPolicy = securityPolicy;
                self.securityPolicy.allowInvalidCertificates = YES;
            }
        }
        /** 返回类型 */
        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(responseSerializerType)]) {
            switch (apiManager.apiConfigDelegate.responseSerializerType) {
                case BTResponseSerializerTypeHTTP:
                    self.responseSerializer = [AFHTTPResponseSerializer serializer];break;
                case BTResponseSerializerTypeJSON:
                {
                    self.responseSerializer = [AFJSONResponseSerializer serializer];
                    ((AFJSONResponseSerializer *)self.responseSerializer).removesKeysWithNullValues = YES;
                    break;
                }
                default:
                    break;
            }
        }
        
        /** 支持格式 */
        self.responseSerializer.acceptableContentTypes = [BGNetworkManager NetworkAcceptableContentTypes];
        
        /** 发送类型 */
        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(requestSerializerType)]) {
            switch (apiManager.apiConfigDelegate.requestSerializerType) {
                case BTRequestSerializerTypeHTTP:
                    self.requestSerializer = [AFHTTPRequestSerializer serializer];break;
                case BTRequestSerializerTypeJSON:
                    self.requestSerializer = [AFJSONRequestSerializer serializer];break;
                default:
                    break;
            }
        }
        
        /** 超时 时长 */
        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(requestTimeoutInterval)]) {
            self.requestSerializer.timeoutInterval = apiManager.apiConfigDelegate.requestTimeoutInterval;
        } else {
            self.requestSerializer.timeoutInterval =  kDEFAULT_REQUEST_TIMEOUT;
        }
        /** 请求头 */
        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(requestHeaderFieldDictionary)]) {
            [apiManager.apiConfigDelegate.requestHeaderFieldDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key isKindOfClass:[NSString class]] && [obj isKindOfClass:[NSString class]]) {
                    [self.requestSerializer setValue:obj forHTTPHeaderField:key];
                }
            }];
        }
        
        
    }
    return self;
}
@end

@interface BGNetworkManager ()
@property (nonatomic,strong) NSMutableDictionary *taskTable;
@end

@implementation BGNetworkManager
+ (instancetype)shareManager{
    static BGNetworkManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [BGNetworkManager new];
    });
    return manager;
}

-(void)dealloc{NSLog(@"dalloc -- %@",NSStringFromClass([self class]));}

- (instancetype)init {
    if (self = [super init]) {
        _taskTable = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - custom Method
- (NSString *)dataRequestWithApiManager:(BGBaseApiManager *)apiManager
                            extraMethod:(BGRequestMethod)extraMethod
                                    url:(NSString *)url
                                 params:(NSDictionary *)params
                       completionHandle:(BGNetworkCompletionBlcok)completionHandle{
    
    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(isEnableCache)]) {
        
        if (apiManager.apiConfigDelegate.isEnableCache) {//开启了缓存
            if ([apiManager.apiConfigDelegate respondsToSelector:@selector(cacheDBId)]) {
                NSString *ID_name = [apiManager.apiConfigDelegate cacheDBId];
                
                if ([apiManager.apiConfigDelegate respondsToSelector:@selector(cacheDataTime)]) {
                    NSInteger cacheTime = apiManager.apiConfigDelegate.cacheDataTime;
                    
                    for (NSString *filename in [BGNetworkManager sortSubpathsOfDirectoryAtPath:[BGNetworkManager cacheFloder]]) {
                        if ([filename containsString:ID_name]) {//文件存在
                            NSArray *d = [filename componentsSeparatedByString:@"*"];
                            NSString *date_s = d.firstObject;
                            
                            NSString *now_d = [BGNetworkManager getNowtimeFormatter];
                            NSInteger second = [BGNetworkManager dateTimeDifferenceWithT1:date_s t2:now_d];
                            NSString *dest_s = [[BGNetworkManager cacheFloder] stringByAppendingPathComponent:filename];
                            
                            if (second < cacheTime) {//缓存时间内
                                
                                NSData *d = [[NSData alloc] initWithContentsOfFile:dest_s];
                                NSError *error = nil;
                                id responseObject = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:&error];
                                if (completionHandle) {
                                    completionHandle(responseObject,error,BGResponseDataTypeCache);
                                    //-1表示无效任务是缓存数据
                                    return @"-1";
                                }
                            } else {
                                //清空缓存
                                [[NSFileManager defaultManager] removeItemAtPath:dest_s error:nil];
                            }
                            break;
                        }
                    }
                    
                    
                } else{
                    NSLog(@"cacheDataTime 缓存时长协议未实现");
                }
                
            } else {
                NSLog(@"cacheDBId 网络数据缓存协议未设置缓存主键");
            }
        } else {
            
            if ([apiManager.apiConfigDelegate respondsToSelector:@selector(cacheDBId)]) {
                NSString *ID_name = apiManager.apiConfigDelegate.cacheDBId;
                if ([ID_name union_isExist]) {
                    
                    for (NSString *filename in [BGNetworkManager sortSubpathsOfDirectoryAtPath:[BGNetworkManager cacheFloder]]) {
                        if ([filename containsString:ID_name]) {//文件存在
                            NSString *dest_s = [[BGNetworkManager cacheFloder] stringByAppendingPathComponent:filename];
                            [[NSFileManager defaultManager] removeItemAtPath:dest_s error:nil];
                            break;
                        }
                    }
                }
            }
        }
    }
    
    
    BGHTTPSessionManager *sessionManager = [[BGHTTPSessionManager alloc] initWithApiManager:apiManager];
    
    //是否允许请求重定向
    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(enableRedirection)]) {
        
        if ([apiManager.apiConfigDelegate enableRedirection]) {
            [sessionManager setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest *(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request) {
                if (response) {
                    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(redirectionUrl:originParam:originReqUrl:)]) {
                        [apiManager.apiConfigDelegate redirectionUrl:request.URL
                                                         originParam:params
                                                        originReqUrl:url];
                    }
                    return nil;
                }
                return request;
            }];
        }
    }
    
    /** 获取api中的环境 拼接接口 参数 是否要修改接口请求类型【GET/POST】 */
    NSURLRequest *urlRequest = [self urlRequestWithSessionManager:sessionManager
                                                       apiManager:apiManager
                                                      extraMethod:extraMethod
                                                       requestUrl:url
                                                     requestParam:params];
    
    
    __block NSURLSessionDataTask *dataTask = nil;
    NSString *task_id = [NSDate union_date_type2];
    
    dataTask = [sessionManager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //        NSString *task_id = intToString(dataTask.taskIdentifier);
        [sessionManager invalidateSessionCancelingTasks:YES];
        
        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(responeAllHttpHeaders:)]) {
            NSHTTPURLResponse *re = (NSHTTPURLResponse *)response;
            [apiManager.apiConfigDelegate responeAllHttpHeaders:re.allHeaderFields];
        }
        
        @synchronized(self) {
            
            if ([self.taskTable.allKeys containsObject:task_id]) {
                KCLog(@"task_id--- remove -- %@",task_id);
                [self.taskTable removeObjectForKey:task_id];
            }
        }
        
        if (completionHandle) {
            //格式化一下
            if (responseObject && !error) {
                //判断相应数据是否满足业务需求
                BOOL meetBusinessNeed = YES;
                if ([apiManager.apiConfigDelegate respondsToSelector:@selector(areBusinessNeedMeetWithResponseObject:)])  {
                    meetBusinessNeed =  [apiManager.apiConfigDelegate areBusinessNeedMeetWithResponseObject:responseObject];
                }
                //满足满足业务需求 && 无错
                if (meetBusinessNeed && !error) {
                    if ([NSJSONSerialization isValidJSONObject:responseObject]){
                        NSData *d = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];;
                        responseObject = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil];
                        
                        
                        /** 设置网络层数据缓存 */
                        
                        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(isEnableCache)]) {
                            if (apiManager.apiConfigDelegate.isEnableCache) {//开启了缓存
                                if ([apiManager.apiConfigDelegate respondsToSelector:@selector(cacheDBId)]) {
                                    NSString *ID_name = [apiManager.apiConfigDelegate cacheDBId];
                                    NSString *f_n = F(@"%@*%@",[BGNetworkManager getNowtimeFormatter],ID_name);
                                    NSString *dest_s = F(@"%@.json",[[BGNetworkManager cacheFloder] stringByAppendingPathComponent:f_n]);
                                    [d writeToFile:dest_s atomically:YES];
                                } else {
                                    KCLog(@"cacheDBId 网络数据缓存协议未设置缓存主键");
                                }
                            }
                        }
                    }
                    completionHandle(responseObject, error,BGResponseDataTypeRemote);
                }else {
                    //判断是否需要重试请求
                    BOOL needRetryReq = NO;
                    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(needRetryReq)])  {
                        needRetryReq =  [apiManager.apiConfigDelegate needRetryReq];
                    }
                    if (needRetryReq) {
                        //重试请求间隔，默认1秒
                        int retryReqInterval = 1;
                        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(retryReqInterval)]) {
                            retryReqInterval = [apiManager.apiConfigDelegate retryReqInterval];
                        }
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryReqInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self retryWithUrlRequest:urlRequest apiManager:apiManager currentRetryReqTime:0 completionHandle:completionHandle];
                        });
                        
                    }else {
                        //不符合业务需求
                        completionHandle(responseObject, error,BGResponseDataTypeRemoteInvalid);
                    }
                    
                    
                }
                
            } else {
                BOOL meetBusinessNeed = YES;
                if ([apiManager.apiConfigDelegate respondsToSelector:@selector(areBusinessNeedMeetWithResponseObject:)])  {
                    meetBusinessNeed =  [apiManager.apiConfigDelegate areBusinessNeedMeetWithResponseObject:responseObject];
                }
                
                if (meetBusinessNeed && !error) {
                    completionHandle(responseObject, error,BGResponseDataTypeRemote);
                }else {
                    //判断是否需要重试请求
                    BOOL needRetryReq = NO;
                    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(needRetryReq)])  {
                        needRetryReq =  [apiManager.apiConfigDelegate needRetryReq];
                    }
                    if (needRetryReq) {
                        
                        //重试请求间隔，默认1秒
                        int retryReqInterval = 1;
                        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(retryReqInterval)]) {
                            retryReqInterval = [apiManager.apiConfigDelegate retryReqInterval];
                        }
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryReqInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self retryWithUrlRequest:urlRequest apiManager:apiManager currentRetryReqTime:0 completionHandle:completionHandle];
                        });
                    }else {
                        completionHandle(responseObject, error,BGResponseDataTypeRemoteInvalid);
                    }
                }
            }
            
            
        }
    }];
    
    //    NSString *task_id = intToString(dataTask.taskIdentifier);
    @synchronized(self) {
        KCLog(@"task_id--- create -- %@",task_id);
        [self.taskTable setValue:dataTask forKey:task_id];
    }
    
    [dataTask resume];
    return task_id;
}

//请求重试
- (NSString*)retryWithUrlRequest:(NSURLRequest* )urlRequest
                      apiManager:(BGBaseApiManager *)apiManager
             currentRetryReqTime:(int)currentRetryReqTime
                completionHandle:(BGNetworkCompletionBlcok)completionHandle{
    
    //    NSLog(@"%@ 请求重试第%d次",urlRequest.URL.absoluteString,currentRetryReqTime);
    
    BGHTTPSessionManager *sessionManager = [[BGHTTPSessionManager alloc] initWithApiManager:apiManager];
    
    //重试请求间隔，默认1秒
    int retryReqInterval = 1;
    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(retryReqInterval)]) {
        retryReqInterval = [apiManager.apiConfigDelegate retryReqInterval];
    }
    //最多重试请求次数，默认3次
    int maxRetryReqTimes = 3;
    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(maxRetryReqTimes)]) {
        maxRetryReqTimes = [apiManager.apiConfigDelegate maxRetryReqTimes];
    }
    //是否需要重试
    BOOL needRetryReq = NO;
    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(needRetryReq)])  {
        needRetryReq =  [apiManager.apiConfigDelegate needRetryReq];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    NSString *task_id = [NSDate union_date_type2];
    
    dataTask = [sessionManager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        //        NSString *task_id = intToString(dataTask.taskIdentifier);
        [sessionManager invalidateSessionCancelingTasks:YES];
        
        
        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(responeAllHttpHeaders:)]) {
            NSHTTPURLResponse *re = (NSHTTPURLResponse *)response;
            [apiManager.apiConfigDelegate responeAllHttpHeaders:re.allHeaderFields];
        }
        
        @synchronized(self) {
            
            if ([self.taskTable.allKeys containsObject:task_id]) {
                KCLog(@"task_id--- remove -- %@",task_id);
                [self.taskTable removeObjectForKey:task_id];
            }
        }
        
        if (completionHandle) {
            
            //到maxRetryReqTimes次了，跳出递归，执行completionHandle
            if (currentRetryReqTime == maxRetryReqTimes) {
                BOOL meetBusinessNeed = YES;
                if ([apiManager.apiConfigDelegate respondsToSelector:@selector(areBusinessNeedMeetWithResponseObject:)])  {
                    meetBusinessNeed =  [apiManager.apiConfigDelegate areBusinessNeedMeetWithResponseObject:responseObject];
                }
                
                
                if (responseObject && meetBusinessNeed) {
                    if ([NSJSONSerialization isValidJSONObject:responseObject]){
                        NSData *d = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];;
                        responseObject = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil];
                        
                        
                        /** 设置网络层数据缓存 */
                        
                        if ([apiManager.apiConfigDelegate respondsToSelector:@selector(isEnableCache)]) {
                            if (apiManager.apiConfigDelegate.isEnableCache) {//开启了缓存
                                if ([apiManager.apiConfigDelegate respondsToSelector:@selector(cacheDBId)]) {
                                    NSString *ID_name = [apiManager.apiConfigDelegate cacheDBId];
                                    NSString *f_n = F(@"%@*%@",[BGNetworkManager getNowtimeFormatter],ID_name);
                                    NSString *dest_s = F(@"%@.json",[[BGNetworkManager cacheFloder] stringByAppendingPathComponent:f_n]);
                                    [d writeToFile:dest_s atomically:YES];
                                } else {
                                    KCLog(@"cacheDBId 网络数据缓存协议未设置缓存主键");
                                }
                            }
                        }
                    }
                    completionHandle(responseObject, error,BGResponseDataTypeRemote);
                } else {
                    
                    completionHandle(responseObject, error,BGResponseDataTypeRemoteInvalid);
                }
                
            }else {
                
                //格式化一下
                if (responseObject && !error) {
                    //                    NSData *d = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];;
                    //                    NSDictionary *testresponseObject = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil];
                    //
                    //                    NSLog(@"%@ 请求结果 hadError:%d responseObject: %@ ",urlRequest.URL.absoluteString,error?1:0, testresponseObject);
                    
                    //判断相应数据是否满足业务需求
                    BOOL meetBusinessNeed = YES;
                    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(areBusinessNeedMeetWithResponseObject:)])  {
                        meetBusinessNeed =  [apiManager.apiConfigDelegate areBusinessNeedMeetWithResponseObject:responseObject];
                    }
                    //满足满足业务需求 && 无错
                    if (meetBusinessNeed && !error) {
                        if ([NSJSONSerialization isValidJSONObject:responseObject]){
                            NSData *d = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];;
                            responseObject = [NSJSONSerialization JSONObjectWithData:d options:NSJSONReadingMutableContainers error:nil];
                            
                            
                            /** 设置网络层数据缓存 */
                            
                            if ([apiManager.apiConfigDelegate respondsToSelector:@selector(isEnableCache)]) {
                                if (apiManager.apiConfigDelegate.isEnableCache) {//开启了缓存
                                    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(cacheDBId)]) {
                                        NSString *ID_name = [apiManager.apiConfigDelegate cacheDBId];
                                        NSString *f_n = F(@"%@*%@",[BGNetworkManager getNowtimeFormatter],ID_name);
                                        NSString *dest_s = F(@"%@.json",[[BGNetworkManager cacheFloder] stringByAppendingPathComponent:f_n]);
                                        [d writeToFile:dest_s atomically:YES];
                                    } else {
                                        KCLog(@"cacheDBId 网络数据缓存协议未设置缓存主键");
                                    }
                                }
                            }
                        }
                        completionHandle(responseObject, error,BGResponseDataTypeRemote);
                        //不满足重试
                    }else {
                        //判断是否需要重试请求
                        
                        if (needRetryReq) {
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryReqInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self retryWithUrlRequest:urlRequest apiManager:apiManager currentRetryReqTime:currentRetryReqTime+1 completionHandle:completionHandle];
                            });
                        }else {
                            
                            completionHandle(responseObject, error,BGResponseDataTypeRemote);
                        }
                        
                    }
                    
                }else {
                    BOOL meetBusinessNeed = YES;
                    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(areBusinessNeedMeetWithResponseObject:)])  {
                        meetBusinessNeed =  [apiManager.apiConfigDelegate areBusinessNeedMeetWithResponseObject:responseObject];
                    }
                    //满足满足业务需求 && 无错
                    if (meetBusinessNeed && !error) {
                        completionHandle(responseObject, error,BGResponseDataTypeRemote);
                        //不满足重试
                    }else {
                        
                        //判断是否需要重试请求
                        if (needRetryReq) {
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(retryReqInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                [self retryWithUrlRequest:urlRequest apiManager:apiManager currentRetryReqTime:currentRetryReqTime+1 completionHandle:completionHandle];
                            });
                        }else {
                            
                            completionHandle(responseObject, error,BGResponseDataTypeRemote);
                        }
                    }
                }
                
            }
            
        }
    }];
    
    
    //    NSString *task_id = intToString(dataTask.taskIdentifier);
    @synchronized(self) {
        KCLog(@"task_id--- create -- %@",task_id);
        [self.taskTable setValue:dataTask forKey:task_id];
    }
    
    [dataTask resume];
    
    return task_id;
}

- (NSString *)uploadRequestWithApiManager:(BGBaseApiManager *)apiManager
                                      url:(NSString *)url
                                   params:(NSDictionary *)params
                               uploadType:(BGUploadType)uploadType
                                    datas:(NSArray *)datas
                            progressBlock:(BGProgressBlock)progress
                         completionHandle:(BGNetworkCompletionBlcok)completionHandle{
    NSAssert(url, @"上传任务 url 不可为空");
    BGHTTPSessionManager *manager = [[BGHTTPSessionManager alloc] initWithApiManager:apiManager];
    NSError *error = nil;
    NSLog(@"requestMethod# %@ \n http_url# %@ \n params# %@  \n",@"POST",url,params);
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        switch (uploadType) {
            case BGUploadTypeImg:
            {
                for (UIImage *img in datas) {
                    if ([img isKindOfClass:[UIImage class]]) {
                        NSData *data = [BGNetworkManager compressImage:img toMaxFileSize:1024];
                        [formData appendPartWithFileData:data
                                                    name:kServerImagePath
                                                fileName:@".png"
                                                mimeType:@"image/png"];
                    }
                }
            }
                break;
            case BGUploadTypeImgPath:
            {
                for (NSString *file_img in datas) {
                    if ([file_img isKindOfClass:[NSString class]]) {
                        [formData appendPartWithFileURL:[NSURL fileURLWithPath:file_img]
                                                   name:kServerImagePath
                                               fileName:@".png"
                                               mimeType:@"image/png"
                                                  error:nil];
                    }
                }
            }
                break;
            case BGUploadTypeFilePath:
            {
                for (NSString *file in datas) {
                    if ([file isKindOfClass:[NSString class]]) {
                        NSData *data = [NSData dataWithContentsOfFile:file];
                        [formData appendPartWithFileData:data
                                                    name:kServerFilePath
                                                fileName:@".file"
                                                mimeType:@"image/png"];
                    }
                }
            }
                break;
            case BGUploadTypeZipPath:
            {
                for (NSString *file in datas) {
                    if ([file isKindOfClass:[NSString class]]) {
                        NSData *data = [NSData dataWithContentsOfFile:file];
                        [formData appendPartWithFileData:data
                                                    name:kServerZipPath
                                                fileName:@".zip"
                                                mimeType:@"zip"];
                    }
                }
            }
                break;
            default:
                break;
        }
    } error:&error];
    
    if (error) {
        completionHandle(nil,error,BGResponseDataTypeRemote);
        return nil;
    } else {
        NSURLSessionUploadTask *dataTask = nil;
        dataTask = [manager uploadTaskWithStreamedRequest:request
                                                 progress:progress
                                        completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                            NSString *task_id = intToString(dataTask.taskIdentifier);
                                            [manager invalidateSessionCancelingTasks:YES];
                                            
                                            @synchronized(self) {
                                                if ([self.taskTable.allKeys containsObject:task_id]) {
                                                    [self.taskTable removeObjectForKey:task_id];
                                                }
                                            }
                                            
                                            completionHandle(responseObject,error,BGResponseDataTypeRemote);
                                        }];
        
        NSString *task_id = intToString(dataTask.taskIdentifier);
        @synchronized(self) {
            [self.taskTable setValue:dataTask forKey:task_id];
        }
        [dataTask resume];
        return task_id;
    }
}

- (NSString *)downloadRequestWithApiManager:(BGBaseApiManager *)apiManager
                                        url:(NSString *)url
                           destinationBlock:(BGDestinationBlcok)destinationBlock
                              progressBlock:(BGProgressBlock)progress
                           completionHandle:(BGNetworkCompletionBlcok)completionHandle{
    NSLog(@"http_url# %@",url);
    BGHTTPSessionManager *manager = [[BGHTTPSessionManager alloc] initWithApiManager:apiManager];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDownloadTask *downloadTask = nil;
    downloadTask = [manager downloadTaskWithRequest:request
                                           progress:progress
                                        destination:destinationBlock
                                  completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                      NSString *task_id = intToString(downloadTask.taskIdentifier);
                                      [manager invalidateSessionCancelingTasks:YES];
                                      
                                      @synchronized(self) {
                                          if ([self.taskTable.allKeys containsObject:task_id]) {
                                              [self.taskTable removeObjectForKey:task_id];
                                          }
                                      }
                                      if (completionHandle) {
                                          completionHandle(filePath, error,BGResponseDataTypeRemote);
                                      }
                                  }];
    NSString *task_id = intToString(downloadTask.taskIdentifier);
    @synchronized(self) {
        [self.taskTable setValue:downloadTask forKey:task_id];
    }
    [downloadTask resume];
    return task_id;
}

- (NSURLRequest *)urlRequestWithSessionManager:(BGHTTPSessionManager *)sessionManager
                                    apiManager:(BGBaseApiManager *)apiManager
                                   extraMethod:(BGRequestMethod)extraMethod
                                    requestUrl:(NSString *)requestUrl
                                  requestParam:(NSDictionary *)requestParam{
    //当前环境 下 请求的接口
    NSString *http_url = [self getRequestHttp_url:requestUrl withApiManager:apiManager];
    
    NSString *requestType = @"GET";
    switch (extraMethod) {
        case BGRequestMethodDefault:
        {
            if (apiManager.apiConfigDelegate.defaultRequestMethod == BGRequestMethodPost) {
                requestType = @"POST";
            }
        }
            break;
        case BGRequestMethodGet:
            break;
        case BGRequestMethodPost:
            requestType = @"POST";
            break;
        default:
            break;
    }
    
    NSDictionary *params = [self parametersWithApiManager:apiManager
                                             requestParam:requestParam
                                               requestUrl:requestUrl];
    NSLog(@"\n[----- \n requestMethod# %@ \n url:  %@ \n params:   %@ \n reqHeader#\n %@ ----\n]",requestType,http_url,params,sessionManager.requestSerializer.HTTPRequestHeaders);
    
    
    http_url = [http_url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSMutableDictionary *params_m = [NSMutableDictionary dictionary];
    for (NSString *key in params.allKeys) {
        if ([params[key] isKindOfClass:[NSString class]]) {
            NSString *new_key = nil;
            NSString *new_value = nil;
            new_key = [key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            new_value = [params[key] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
            [params_m setValue:new_value forKey:new_key];
        } else {
            [params_m setValue:params[key] forKey:key];
        }
        
    }
    
    NSURLRequest *urlRequest = nil;
    
    urlRequest = [[sessionManager requestSerializer] requestWithMethod:requestType
                                                             URLString:http_url
                                                            parameters:params
                                                                 error:nil];
    
    return urlRequest;
}

- (NSDictionary *)parametersWithApiManager:(BGBaseApiManager *)apiManager requestParam:(NSDictionary *)requestParam requestUrl:(NSString *)requestUrl {
    if ([apiManager.apiConfigDelegate respondsToSelector:@selector(parametersWithRequestParam:requestUrl:)]) {
        requestParam = [apiManager.apiConfigDelegate parametersWithRequestParam:requestParam
                                                                     requestUrl:requestUrl];
    }
    
    return requestParam;
}

- (void)cancelTaskWithUnionId:(NSString *)unionId{
    @synchronized (self) {
        if ([self.taskTable objectForKey:unionId]) {
            NSURLSessionDataTask *requestTask = [self.taskTable objectForKey:unionId];
            if ([requestTask isKindOfClass:[NSURLSessionDownloadTask class]]) {
                //手动取消的下载请求，调用cancelByProducingResumeData:，这样回调的error中会带有resumeData
                NSURLSessionDownloadTask *downloadTask = (NSURLSessionDownloadTask *)requestTask;
                [downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                    
                }];
            } else {
                [requestTask cancel];
            }
            [self.taskTable removeObjectForKey:unionId];
        }
    }
}

- (void)cancelAllRequests{
    for (NSString *requestId in self.taskTable.allKeys) {
        [self cancelTaskWithUnionId:requestId];
    }
}

#pragma mark - Getter & Setter
+ (NSSet<NSString *> *)NetworkAcceptableContentTypes{
    return [NSSet setWithObjects:@"application/json",
            @"text/html",
            @"text/json",
            @"text/plain",
            @"text/javascript",
            @"text/xml",
            @"image/*",nil];
}

- (NSString *)getRequestHttp_url:(NSString *)url withApiManager:(BGBaseApiManager *)apiManager{
    if ([url hasPrefix:@"http"]) {
        return url;
    } else {
        return [apiManager.apiConfigDelegate.serverDomainPath stringByAppendingString:url];
    }
}

+ (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize
{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    return imageData;
}

+ (NSString *)cacheFloder{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *finalS = [[paths firstObject] stringByAppendingPathComponent:@"cacheNetworkData"];
    NSFileManager *file_m = [NSFileManager defaultManager];
    if (![file_m fileExistsAtPath:finalS]) {
        [file_m createDirectoryAtPath:finalS withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return finalS;
}

+ (NSString*)getNowtimeFormatter{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [formatter stringFromDate:date];
}

+ (NSArray *)sortSubpathsOfDirectoryAtPath:(NSString *)path{
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:path error:nil];
    
    NSArray *sortImgs = [files sortedArrayUsingComparator:^NSComparisonResult(NSString *path1, NSString *path2) {
        return (NSComparisonResult)[path1 compare:path2 options:NSNumericSearch];
    }];
    return sortImgs;
}

+ (NSInteger)dateTimeDifferenceWithT1:(NSString *)t1 t2:(NSString *)t2 {
    
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate* startDate = [formater dateFromString:t1];
    NSDate* endDate = [formater dateFromString:t2];
    NSTimeInterval time = [endDate timeIntervalSinceDate:startDate];
    return time;
}

@end
