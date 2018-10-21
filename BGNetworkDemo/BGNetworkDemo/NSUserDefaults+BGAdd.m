//
//  NSUserDefaults+BGAdd.m
//  BGNetworkDemo
//
//  Created by Little.Daddly on 2018/6/4.
//  Copyright © 2018年 Little.Daddly. All rights reserved.
//

#import "NSUserDefaults+BGAdd.h"

@implementation NSUserDefaults (BGAdd)
+ (void)insertValue:(id)value withKey:(NSString *)key{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:value forKey:key];
    [userDefault synchronize];
}

+ (id)fetchValueForKey:(NSString *)key{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault valueForKey:key];
}
@end
