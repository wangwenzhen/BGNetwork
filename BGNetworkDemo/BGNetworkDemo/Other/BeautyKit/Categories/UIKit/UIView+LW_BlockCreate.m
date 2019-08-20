//
//  UIView+LW_BlockCreate.m
//  MVC
//
//  Created by Little.Daddly on 2017/6/25.
//  Copyright © 2017年 Little.Daddly. All rights reserved.
//

#import "UIView+LW_BlockCreate.h"

@implementation UIView (LW_BlockCreate)
+(instancetype)lw_createAddToView:(__kindof UIView*)superView
                      blockConfig:(void(^)(__kindof UIView *))blockConfig{
    
    __kindof UIView *instance = [[self alloc] init];
    
    [superView addSubview:instance];
    [UIView configureV:instance];
    if (blockConfig) {
        blockConfig(instance);
    }
    
    return instance;
}

+(instancetype)lw_createView:(void(^)(__kindof UIView *))blockConfig{
    __kindof UIView *instance = [[self alloc] init];
    [UIView configureV:instance];
    if(blockConfig){
        blockConfig(instance);
    }
    return instance;
}

+ (__kindof UIView *)configureV:(__kindof UIView *)v{
    if ([v isKindOfClass:UILabel.class]) {
        UILabel *l = (UILabel *)v;
        l.font = [UIFont systemFontOfSize:12];
        l.textColor = [UIColor blackColor];
    }
    return v;
}
-(instancetype)lw_AddToView:(__kindof UIView*)superView
                blockConfig:(void(^)(__kindof UIView *))blockConfig{
    
    [superView addSubview:self];
    if (blockConfig) {
        blockConfig(self);
    }
    return self;
}

-(instancetype)lw_View:(void(^)(__kindof UIView *))blockConfig{    
    if(blockConfig){
        blockConfig(self);
    }
    
    return self;
}
@end
