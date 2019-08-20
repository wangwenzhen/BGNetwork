//
//  UIColor+BTExtension.m
//  BeautyMall
//
//  Created by xueMingLuan on 2017/5/5.
//  Copyright © 2017年 BeautyHZ. All rights reserved.
//

#import "UIColor+BTExtension.h"

@implementation UIColor (BTExtension)

+ (UIColor *)union_colorWithHexString:(NSString *)hexString {
    return [self union_colorWithHexString:hexString alpha:1.0f];
}

+ (UIColor *)union_colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6){
        return [UIColor clearColor];
    }
    if ([cString hasPrefix:@"0X"]){
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"]){
        cString = [cString substringFromIndex:1];
    }
    
    if ([cString length] != 6){
        return [UIColor clearColor];
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    //R
    NSString *rString = [cString substringWithRange:range];
    //G
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //B
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

+ (UIColor *)union_colorWithHex:(NSUInteger)hex {
    CGFloat red, green, blue, alpha;
    
    red = ((CGFloat)((hex >> 16) & 0xFF)) / ((CGFloat)0xFF);
    green = ((CGFloat)((hex >> 8) & 0xFF)) / ((CGFloat)0xFF);
    blue = ((CGFloat)((hex >> 0) & 0xFF)) / ((CGFloat)0xFF);
    alpha = hex > 0xFFFFFF ? ((CGFloat)((hex >> 24) & 0xFF)) / ((CGFloat)0xFF) : 1;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)union_colorWithR:(NSInteger)red G:(NSInteger)green B:(NSInteger)blue {
    return [UIColor colorWithRed:red/ 255.00f green:green/ 255.00f blue:blue/ 255.00f alpha:1.0f];
}

- (UIImage *)union_colorImage {
    return [self union_colorImageWithSize:CGSizeMake(1, 1)];
}

- (UIImage *)union_colorImageWithSize:(CGSize)specSize {
    CGRect rect = CGRectMake(0, 0, specSize.width, specSize.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+ (UIColor *)union_colorWithHex:(NSUInteger)hex alpha:(CGFloat)alpha
{
    return [[UIColor union_colorWithHex:hex] colorWithAlphaComponent:alpha];
}

+ (NSArray *)getRGBDictionaryByColor:(UIColor *)originColor
{
    CGFloat r=0,g=0,b=0,a=0;
    if ([originColor respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
        [originColor getRed:&r green:&g blue:&b alpha:&a];
    }
//    else {
//        const CGFloat *components = CGColorGetComponents(originColor.CGColor);
//        r = components[0];
//        g = components[1];
//        b = components[2];
//        a = components[3];
//    }
    
    return @[@(r),@(g),@(b)];
}

+ (NSArray *)transColorBeginColor:(UIColor *)beginColor andEndColor:(UIColor *)endColor {
    
    NSArray<NSNumber *> *beginColorArr = [UIColor getRGBDictionaryByColor:beginColor];
    
    NSArray<NSNumber *> *endColorArr = @[@(1.0),@(1.0),@(1.0)];
    
    return @[@([endColorArr[0] doubleValue] - [beginColorArr[0] doubleValue]),
             @([endColorArr[1] doubleValue] - [beginColorArr[1] doubleValue]),
             @([endColorArr[2] doubleValue] - [beginColorArr[2] doubleValue])];
    
}

+ (UIColor *)getColorWithColor:(UIColor *)beginColor
                        andCoe:(double)coe
                andMarginArray:(NSArray<NSNumber *> *)marginArray {
    
    NSArray *beginColorArr = [UIColor getRGBDictionaryByColor:beginColor];
    double red = [beginColorArr[0] doubleValue] + coe * [marginArray[0] doubleValue];
    double green = [beginColorArr[1] doubleValue]+ coe * [marginArray[1] doubleValue];
    double blue = [beginColorArr[2] doubleValue] + coe * [marginArray[2] doubleValue];
    return [UIColor union_colorWithR:red*255. G:green*255. B:blue*255.];
    
}
@end
