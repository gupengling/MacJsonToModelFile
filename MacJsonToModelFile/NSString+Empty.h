//
//  NSString+Empty.h
//
//  Created by gupengling on 15/10/23.
//  Copyright © 2015年 gupengling. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_Empty)
+(BOOL) isBlank:(NSString*)str;
+(NSString *)validateStr:(NSString*)str;

//过滤掉因为复制粘贴带来的行号
+ (NSString*)replace1WithContent:(NSString*)content regexStr:(NSString*)regexStr;
+ (NSString*)replace2WithContent:(NSString*)content regexStr:(NSString*)regexStr;

//获取字符串首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)getFirstLetterFromString;
@end
