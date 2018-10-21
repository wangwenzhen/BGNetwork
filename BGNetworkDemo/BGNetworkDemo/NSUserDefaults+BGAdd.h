//
//  NSUserDefaults+BGAdd.h
//  BGNetworkDemo
//
//  Created by Little.Daddly on 2018/6/4.
//  Copyright © 2018年 Little.Daddly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (BGAdd)
+ (void)insertValue:(id)value withKey:(NSString *)key;
+ (id)fetchValueForKey:(NSString *)key;
@end
