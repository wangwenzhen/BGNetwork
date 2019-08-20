//
//  NSString+BTExtension.h
//  BeautyMall
//
//  Created by xueMingLuan on 2017/4/28.
//  Copyright © 2017年 BeautyHZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (BTExtension)

#pragma mark - 字符串验证相关

- (BOOL)union_isExist;
- (BOOL)union_isEmpty; //这里注意nil/null是走不了这个方法的,判断字符串是否存在最好用union_isExist方法
- (BOOL)union_isEmail;
- (BOOL)union_isValidPhone;
- (BOOL)union_isAllNumber;
- (BOOL)union_isAllChinese;
- (BOOL)union_isAllEnglish;
- (BOOL)union_includeChinese;
- (BOOL)union_contains:(NSString *)string;

/* 手机号验证 */
+ (BOOL)union_isValidateMobile:(NSString *)strMobile;

/**
 是否字符串包含emoji表情
 */
+ (BOOL)union_stringContainsEmoji:(NSString *)string;

/**
 身份证号码验证
 */
+ (BOOL)union_stringIsValidateIdentityCard:(NSString *)identityCard;

/**
 邮箱验证
 */
+ (BOOL)union_stringIsValidateEmail:(NSString *)strEmail;

/**
 删除空格
 */
- (NSString *)union_trimWhitespace;

/** 
 删除首尾空格和换行
 */
- (NSString *)union_trimWhiteSpaceAndEmptyLine;
/** 删除所有空格和换行 */
- (NSString *)union_filpSpaceAndBreak;
/** 
 隐藏敏感信息
 */
+ (NSString *)union_hidePhoneAndEmail:(NSString *)str;

/** 
 获取一个随机的字符串
 */
- (NSString *)union_stringRandomly;

/**
 转换拼音
 */
- (NSString *)union_transformToPinyin;

/**
 用 * 代替字符串
 隐藏手机号与邮箱
 */
- (NSString *)union_replacePhoneAndEmail;

/**
 对一些敏感的字符串进行隐藏
 手机号 & 邮箱
 */
- (NSString *)union_securePhoneAndEmail;

/**
 对后台传过来的URL进行处理
 去除空格、中文编码
 */
- (NSURL *)union_handleURL;

#pragma mark - 字符串尺寸相关

/** 
 获取文本尺寸
 */
- (CGSize)union_stringSizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;;
- (CGSize)union_stringSizeWithFontSize:(NSUInteger)font maxSize:(CGSize)maxSize;
- (CGFloat)union_stringHeightWithFontSize:(NSUInteger)fontSize maxSize:(CGSize)size;
- (CGFloat)union_stringWidthWithFontSize:(NSUInteger)fontSize maxSize:(CGSize)size;
- (CGSize)union_stringSizeWithAttribute:(NSDictionary *)attribute maxSize:(CGSize)maxSize;;

#pragma mark - 加密相关

- (NSString *)union_md5;
- (NSString *)union_sha256;
- (NSString *)union_hmacsha256:(NSString *)key;
- (NSString *)union_urlEncoding;
+ (NSString *)getCurrentTimes;
- (NSString *)sha1;
/**
 是否为表情包 ，不可大量使用 ，场景 检查 虚拟键盘上的表情
 不同系统支持的虚拟键盘表情包种类不一致，unicode 、字形
 参考 ： https://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
 对字符串传入LB进行快照，检查像素是否为 纯黑，黑的为字符串 、 其它的为表情
 
 Warning# 应该注意这是一个CoreGraphics解决方案，不应该像使用常规文本方法那样大量使用
 */
+ (BOOL)isEmoji:(NSString *)character;
//传入秒得到 xx:xx:xx或者xx:xx
+ (NSString *)getYYMMSSFromSS:(NSString *)totalTime;
//传入秒得到  xx分钟xx秒
+ (NSString *)getMMSSFromSS:(NSString *)totalTime;
//是否是存数字
+ (BOOL)isPureInt:(NSString *)string;
@end
