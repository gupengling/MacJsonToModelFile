//
//  NSString+Empty.m
//
//  Created by gupengling on 15/10/23.
//  Copyright © 2015年 gupengling. All rights reserved.
//

#import "NSString+Empty.h"

@implementation  NSString (NSString_Empty)
+ (BOOL) isBlank:(NSString*)str{
    if (str == nil || str == NULL) {
        return YES;
    }
    if ([str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    //去除字符串中的空格
    if ([[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}
+ (NSString *)validateStr:(NSString*)str{
    if ([NSString isBlank:str]) {
        return @"";
    }else{
        return str;
    }
}

//过滤掉因为复制粘贴带来的行号
+ (NSString*)replace1WithContent:(NSString*)content regexStr:(NSString*)regexStr {
    
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:regexStr options: NSRegularExpressionCaseInsensitive error:NULL];
    
    NSArray *array2 = [regex matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    
    
    NSMutableArray *replaceArray=[NSMutableArray array];
    for (NSTextCheckingResult *result in array2) {
        
        [replaceArray addObject:[content substringWithRange:result.range]];
    }
    for (NSString *str in replaceArray) {
        NSString *key =[str componentsSeparatedByString:@"\""].lastObject;
        content =  [content stringByReplacingOccurrencesOfString:str withString:[NSString stringWithFormat:@"\"%@",key]];
    }
    return content;
}
+ (NSString*)replace2WithContent:(NSString*)content regexStr:(NSString*)regexStr{
    
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:regexStr options: NSRegularExpressionCaseInsensitive error:NULL];
    
    NSArray *array2 = [regex matchesInString:content options:NSMatchingReportCompletion range:NSMakeRange(0, content.length)];
    
    NSMutableArray *replaceArray=[NSMutableArray array];
    for (NSTextCheckingResult *result in array2) {
        [replaceArray addObject:[content substringWithRange:result.range]];
    }
    
    for (NSString *str in replaceArray) {
        
        
        NSRegularExpression* regex2 = [NSRegularExpression regularExpressionWithPattern:@"[0-9]+" options: NSRegularExpressionCaseInsensitive error:NULL];
        
        NSArray *array2 = [regex2 matchesInString:str options:NSMatchingReportCompletion range:NSMakeRange(0, str.length)];
        
        
        NSString *re=str;
        if (array2.count>0) {
            NSTextCheckingResult *result=array2.firstObject;
            re = [re substringWithRange:result.range];
        }
        re=[str stringByReplacingOccurrencesOfString:re withString:@""];
        content =  [content stringByReplacingOccurrencesOfString:str withString:re];
    }
    return content;
}

//获取字符串首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)getFirstLetterFromString
{
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:self];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *strPinYin = [str capitalizedString];
    //获取并返回首字母
    return strPinYin ;
}

@end
