//
//  ViewController.m
//  BGNetworkDemo
//
//  Created by Little.Daddly on 2018/6/3.
//  Copyright © 2018年 Little.Daddly. All rights reserved.
//

#import "ViewController.h"
#import "BGUserApiManger.h"
#import <AFNetworking/AFNetworking.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *user_info = @{
                                @"username":@"wanssgwz1as",
                                @"password":@"122"
                                };
//    http://www.blackgold.fun:8001/user/signUp?username=wang&password=11
    /** 注册 */
//    [BGUserApiManger requestUserSignUpParams:user_info completionBlcok:^(id responseObject, NSError *error) {
//        NSLog(@"%@",responseObject);
//    }];
//    [BGUserApiManger requestUserIsCreate: @{@"name":@"wanssgwz1as"} completionBlock:^(id responseObject, NSError *error) {
//        NSLog(@"%@",[responseObject valueForKey:@"code"]);
//    }];
    
    [BGUserApiManger requestUserLoginParams:user_info completionBlock:^(id responseObject, NSError *error) {
        NSLog(@"%@",responseObject);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
